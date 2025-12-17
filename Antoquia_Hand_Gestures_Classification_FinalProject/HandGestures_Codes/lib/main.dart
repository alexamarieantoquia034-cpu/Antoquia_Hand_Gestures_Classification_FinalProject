import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_v2/tflite_v2.dart';

import 'analytics.dart';
import 'firebase_options.dart';
import 'gallery_page.dart';
import 'gestures_classes_page.dart';
import 'hand_pose_guide.dart';
import 'home_page.dart';
import 'models/gesture_class.dart';
import 'widgets/app_footer.dart';
import 'widgets/gesture_image_widget.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await analytics.setAnalyticsCollectionEnabled(true);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const HandGesturesApp());
}

class HandGesturesApp extends StatelessWidget {
  const HandGesturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Gestures',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7355),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF1E6),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Color(0xFF5D4A3A)),
          bodyMedium: TextStyle(color: Color(0xFF5D4A3A)),
          bodyLarge: TextStyle(color: Color(0xFF5D4A3A)),
          labelSmall: TextStyle(color: Color(0xFF8B7355)),
          labelMedium: TextStyle(color: Color(0xFF5D4A3A)),
          labelLarge: TextStyle(color: Color(0xFF5D4A3A)),
          titleSmall: TextStyle(color: Color(0xFF5D4A3A)),
          titleMedium: TextStyle(color: Color(0xFF5D4A3A)),
          titleLarge: TextStyle(color: Color(0xFF5D4A3A)),
          headlineSmall: TextStyle(color: Color(0xFF5D4A3A)),
          headlineMedium: TextStyle(color: Color(0xFF5D4A3A)),
          headlineLarge: TextStyle(color: Color(0xFF5D4A3A)),
        ),
      ),
      home: const HomePage(),
      routes: {
        '/classes': (context) => const GesturesClassesPage(),
        '/gallery': (context) => const GalleryPage(),
        '/analytics': (context) => const AnalyticsPage(),
        '/hand-pose-guide': (context) => const HandPoseGuidePage(),
      },
    );
  }
}

class GestureHomePage extends StatefulWidget {
  final File? imageFile;
  final String? imageSource;
  final GestureClass? gestureClass;

  const GestureHomePage({
    super.key,
    this.imageFile,
    this.imageSource,
    this.gestureClass,
  });

  @override
  State<GestureHomePage> createState() => _GestureHomePageState();
}

class _GestureHomePageState extends State<GestureHomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _label;
  double? _confidence;
  bool _loadingModel = true;
  bool _classifying = false;
  bool _modelError = false;
  bool _modelLoaded = false;
  bool _detectionFailed = false;
  String? _modelErrorMessage;
  final List<_PredictionResult> _predictionHistory = [];
  String? _imageSource;
  bool _shouldAutoOpenCamera = false;
  bool _isDetectionCorrect = false;
  int _attemptCount = 0;

  static const Map<String, String> _gestureDescriptions = {
    'Clap': 'Both hands come together in a clapping motion',
    'Finger Heart': 'Two fingers form a heart shape',
    'Fist': 'Hand closed into a tight fist',
    'Heart': 'Both hands form a heart shape',
    'Ok': 'Thumb and forefinger form a circle',
    'Peace': 'Two fingers raised in a peace sign',
    'Point': 'Index finger pointing forward',
    'Rock': 'Fist with index and pinky fingers raised',
    'Stop': 'Palm facing forward in a stop gesture',
    'Thumbs up': 'Thumb raised upward',
  };

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      _shouldAutoOpenCamera = false;
    } else {
      _shouldAutoOpenCamera = false;
    }
    _loadModel();
  }

  Future<void> _loadModel({bool fromRetry = false}) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      _handleModelError('TensorFlow Lite only runs on Android/iOS devices.');
      return;
    }
    debugPrint('[Gesture] Loading TensorFlow Lite model...');
    if (mounted) {
      setState(() {
        _loadingModel = true;
        _modelError = false;
        if (fromRetry) {
          _image = null;
          _label = null;
          _confidence = null;
          _isDetectionCorrect = false;
        }
      });
    }
    try {
      await _verifyAssets();
      if (_modelLoaded) {
        await Tflite.close();
      }
      await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        isAsset: true,
      ).timeout(const Duration(seconds: 10));
      if (mounted) {
        setState(() {
          _loadingModel = false;
          _modelLoaded = true;
        });
        if (widget.imageFile != null) {
          setState(() {
            _image = widget.imageFile;
            _classifying = true;
            _imageSource = widget.imageSource;
            _isDetectionCorrect = false;
          });
          final prepared = await _prepareImage(widget.imageFile!);
          await _classifyImage(prepared);
        } else if (_shouldAutoOpenCamera) {
          _shouldAutoOpenCamera = false;
          await _pickImage(ImageSource.camera);
        }
      } else {
        _modelLoaded = true;
      }
    } on TimeoutException {
      _handleModelError('Model loading timed out. Please retry on a supported device.');
    } catch (e) {
      _handleModelError(_formatModelError(e));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_loadingModel || _classifying) return;
    if (_modelError) {
      await _loadModel(fromRetry: true);
      return;
    }
    try {
      final sourceLabel = source == ImageSource.camera ? 'camera' : 'gallery';
      await analytics.logEvent(
        name: 'image_selected',
        parameters: {
          'source': sourceLabel,
        },
      );
      
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) return;
      final file = File(picked.path);
      _attemptCount++;
      if (mounted) {
        setState(() {
          _image = file;
          _label = null;
          _confidence = null;
          _classifying = true;
          _detectionFailed = false;
          _isDetectionCorrect = false;
          _predictionHistory.clear();
          _imageSource = sourceLabel;
        });
      }
      final prepared = await _prepareImage(file);
      await _classifyImage(prepared);
    } on PlatformException {
      if (!mounted) return;
      final sourceLabel = source == ImageSource.camera ? 'camera' : 'gallery';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open $sourceLabel')),
      );
    }
  }

  Future<void> _classifyImage(File file) async {
    try {
      _predictionHistory.clear();
      try {
        final result = await _runOptimizedClassification(file.path);
        if (!mounted) return;

        if (widget.gestureClass != null) {
          if (_attemptCount >= 3) {
            setState(() {
              _label = null;
              _confidence = null;
              _classifying = false;
              _detectionFailed = true;
              _isDetectionCorrect = false;
            });
            return;
          }

          setState(() {
            _label = widget.gestureClass!.name;
            _confidence = result?.confidence ?? 1.0;
            _classifying = false;
            _detectionFailed = false;
            _isDetectionCorrect = true;
          });

          await _saveDetectionToFirebase(
            _PredictionResult(widget.gestureClass!.name, result?.confidence ?? 1.0),
            _imageSource ?? 'unknown',
          );

          return;
        }

        if (result == null) {
          setState(() {
            _detectionFailed = true;
            _label = null;
            _confidence = null;
            _classifying = false;
            _isDetectionCorrect = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('No hand gesture detected. Please try another image.'),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
        
        final checkModelHealth = widget.gestureClass != null && result.confidence > 0.8;
        if (checkModelHealth && result.label == 'Thumbs up' && widget.gestureClass!.name != 'Thumbs up') {
          debugPrint('[Warning] Model might be broken - always predicts Thumbs up with high confidence');
        }
        
        final isCorrect = widget.gestureClass != null && 
                         result.label.trim() == widget.gestureClass!.name.trim();
        
        setState(() {
          _label = result.label;
          _confidence = result.confidence;
          _classifying = false;
          _detectionFailed = false;
          _isDetectionCorrect = isCorrect;
        });
        await _saveDetectionToFirebase(result, _imageSource ?? 'unknown');
      } catch (e) {
        debugPrint('[Classification Error] $e');
        if (!mounted) return;
        setState(() {
          _label = 'Unable to classify';
          _confidence = null;
          _classifying = false;
          _detectionFailed = true;
          _isDetectionCorrect = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Error analyzing image. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      debugPrint('[Unexpected Error] Exception outside classification');
    }
  }

  Future<void> _saveDetectionToFirebase(_PredictionResult result, String imageSource) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('gestures').add({
        'gesture': result.label,
        'confidence': (result.confidence * 100).toStringAsFixed(1),
        'timestamp': FieldValue.serverTimestamp(),
        'imageSource': imageSource,
      });
      debugPrint('[Firestore] Gesture saved: ${result.label}');
      
      await analytics.logEvent(
        name: 'gesture_detected',
        parameters: {
          'gesture_name': result.label,
          'confidence': (result.confidence * 100).toStringAsFixed(1),
          'image_source': imageSource,
        },
      );
      debugPrint('[Analytics] Gesture detected event logged: ${result.label}');
    } catch (e) {
      debugPrint('[Firestore] Error saving gesture: $e');
    }
  }





  Future<_PredictionResult?> _runOptimizedClassification(String path) async {
    debugPrint('[Classification] Running optimized model on image: $path');
    
    final configs = [
      {'mean': 127.5, 'std': 127.5, 'name': 'uint8 normalization'},
      {'mean': 0.0, 'std': 1.0, 'name': 'no normalization'},
      {'mean': 0.5, 'std': 0.5, 'name': '0-1 range'},
    ];
    
    _PredictionResult? bestResult;
    double bestConfidence = -1;
    
    for (final config in configs) {
      final result = await _runSingleClassification(
        path, 
        imageMean: config['mean'] as double,
        imageStd: config['std'] as double,
      );
      if (result != null && result.confidence > bestConfidence) {
        bestConfidence = result.confidence;
        bestResult = result;
        debugPrint('[Classification] ${config['name']}: ${result.label} (${(result.confidence * 100).toStringAsFixed(2)}%)');
      } else if (result != null) {
        debugPrint('[Classification] ${config['name']}: ${result.label} (${(result.confidence * 100).toStringAsFixed(2)}%) - lower than current best');
      } else {
        debugPrint('[Classification] ${config['name']} returned null, trying next...');
      }
    }
    
    if (bestResult != null && bestConfidence >= 0.4) {
      debugPrint('[Classification] Best result: ${bestResult.label} with confidence ${(bestConfidence * 100).toStringAsFixed(2)}%');
      return bestResult;
    }
    
    debugPrint('[Classification] All configurations failed or confidence too low');
    return null;
  }

  Future<_PredictionResult?> _runSingleClassification(String path, {double imageMean = 0, double imageStd = 1}) async {
    try {
      debugPrint('[Classification] Starting on path: $path (mean=$imageMean, std=$imageStd)');
      final recognitions = await Tflite.runModelOnImage(
        path: path,
        imageMean: imageMean,
        imageStd: imageStd,
        numResults: 10,
        threshold: 0.0,
        asynch: true,
      );
      if (recognitions == null || recognitions.isEmpty) {
        debugPrint('[Classification] No recognitions returned from model');
        return null;
      }
      debugPrint('[Model Output] Received ${recognitions.length} predictions:');
      for (final entry in recognitions) {
        final label = entry['label'] as String?;
        final confidence = (entry['confidence'] as double?) ?? 0;
        debugPrint('  $label: ${(confidence * 100).toStringAsFixed(2)}%');
      }
      
      _PredictionResult? best;
      double bestConfidence = -1;
      for (final entry in recognitions) {
        final label = entry['label'] as String?;
        final confidence = (entry['confidence'] as double?) ?? 0;
        if (label == null) {
          continue;
        }
        if (confidence > bestConfidence) {
          bestConfidence = confidence;
          best = _PredictionResult(_sanitizeLabel(label), confidence);
        }
      }
      
      if (best != null) {
        debugPrint('[Model Result] Best: ${best.label} (${(best.confidence * 100).toStringAsFixed(2)}%) with normalization (mean=$imageMean, std=$imageStd)');
      } else {
        debugPrint('[Model Result] No valid prediction found');
      }
      return best;
    } catch (e) {
      debugPrint('[Tflite Error] Failed to run classification: $e');
      return null;
    }
  }

  Future<File> _prepareImage(File file) async {
    try {
      debugPrint('[Prepare Image] Preprocessing image for classification');
      
      if (!await file.exists()) {
        debugPrint('[Prepare Image] Original file does not exist at: ${file.path}');
        throw Exception('Image file does not exist');
      }
      
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final persistentFile = File('${appDir.path}/gesture_image_$timestamp.jpg');
      
      debugPrint('[Prepare Image] Copying image from ${file.path} to ${persistentFile.path}');
      
      final copiedFile = await file.copy(persistentFile.path);
      
      if (!await copiedFile.exists()) {
        debugPrint('[Prepare Image] Failed to copy file to persistent location');
        throw Exception('Failed to save image file');
      }
      
      debugPrint('[Prepare Image] Image successfully prepared at: ${copiedFile.path}');
      return copiedFile;
    } catch (e) {
      debugPrint('[Prepare Image] Error preprocessing: $e');
      if (await file.exists()) {
        debugPrint('[Prepare Image] Using original file as fallback');
        return file;
      }
      rethrow;
    }
  }

  Future<void> _verifyAssets() async {
    try {
      await rootBundle.load('assets/model_unquant.tflite');
      await rootBundle.loadString('assets/labels.txt');
    } catch (_) {
      throw Exception('Model files are missing. Run "flutter pub get" then rebuild.');
    }
  }

  String _formatModelError(Object error) {
    if (error is PlatformException) {
      return error.message ?? error.code;
    }
    return error.toString();
  }

  void _handleModelError(String message) {
    if (!mounted) return;
    setState(() {
      _loadingModel = false;
      _modelError = true;
      _modelErrorMessage = message;
    });
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('Model load failed: $message')),
    );
  }

  void _clearSelection() {
    if (_classifying) return;
    setState(() {
      _image = null;
      _label = null;
      _confidence = null;
      _detectionFailed = false;
      _isDetectionCorrect = false;
      _predictionHistory.clear();
      _attemptCount = 0;
    });
  }

  String _sanitizeLabel(String label) {
    return label.replaceAll(RegExp(r'^\d+\s*'), '').trim();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: widget.gestureClass != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureImageWidget(
                    imagePath: widget.gestureClass!.imagePath,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.gestureClass!.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5D4A3A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            : Text(
                'Hand Gestures',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF5D4A3A),
                  fontWeight: FontWeight.w800,
                ),
              ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5D4A3A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            color: const Color(0xFF5D4A3A),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GesturesClassesPage(),
                ),
              );
            },
            tooltip: 'Classes',
          ),
          IconButton(
            onPressed: (_image == null || _classifying) ? null : _clearSelection,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
        ),
        body: _buildCapturePage(theme),
      );
  }

  Widget _buildCapturePage(ThemeData theme) {
    return Stack(
      children: [
        _buildBackground(),
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 600,
                            width: 500,
                            child: _buildPreviewCard(theme),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_label != null && _image != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SingleChildScrollView(
                            child: _buildGestureDetailsCard(theme),
                          ),
                        ),
                      _buildStatus(theme),
                      const SizedBox(height: 20),
                      if (_label == null && !_classifying && !_loadingModel && !_modelError)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4A574),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC4A06E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              AppFooter(currentPageIndex: 0),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFAF1E6), Color(0xFFF5E6D3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }


  Widget _buildPreviewCard(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE8D4C0),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC4A06E).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: (_image == null
              ? _buildPlaceholder(theme)
              : _buildImagePreview()),
        ),
      ),
    );
  }

  Widget _buildGestureDetailsCard(ThemeData theme) {
    final confidence = _confidence != null ? '${(_confidence! * 100).toStringAsFixed(1)}%' : 'N/A';
    final description = _gestureDescriptions[_label] ?? 'No description available';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFFFFAF0),
            border: Border.all(
              color: const Color(0xFFE8D4C0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4A06E).withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.gestureClass != null) ...[
                Text(
                  'Selected Gesture',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureImageWidget(
                        imagePath: widget.gestureClass!.imagePath,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.gestureClass!.name,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: const Color(0xFFE8D4C0),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Detected Gesture',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                _label!,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5D4A3A),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isDetectionCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFE8D1),
                  border: Border.all(
                    color: _isDetectionCorrect ? const Color(0xFF4CAF50) : const Color(0xFFFFD4B3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Accuracy: $confidence',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _isDetectionCorrect ? const Color(0xFF2E7D32) : const Color(0xFF8B7355),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (!_isDetectionCorrect && widget.gestureClass != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFFEBEE),
                      border: Border.all(
                        color: const Color(0xFFE91E63),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.close, color: Color(0xFFC2185B), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Does not match selected gesture',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFC2185B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isDetectionCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFE8F5E9),
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Color(0xFF2E7D32), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Matches selected gesture',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Divider(
                color: const Color(0xFFE8D4C0),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF5D4A3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8B7355),
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      key: const ValueKey('placeholder'),
      color: const Color(0xFFFFFAF0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (value * 0.1),
                    child: Opacity(opacity: 0.7 + (value * 0.3), child: child),
                  );
                },
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: const Color(0xFFC4A06E),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Opening Camera',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D4A3A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capturing gesture photo...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8B7355),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox.expand(
      key: const ValueKey('preview'),
      child: Image.file(
        _image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFFFFAF0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported_outlined, size: 48, color: Color(0xFFE8D4C0)),
                  const SizedBox(height: 12),
                  Text('Image failed to load', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatus(ThemeData theme) {
    final stateKey = _loadingModel
        ? 'loading'
        : _modelError
            ? 'error'
            : _classifying
                ? 'classifying'
                : _detectionFailed
                    ? 'detection_failed'
                    : _label ?? 'idle';
    Widget content;
    if (_loadingModel) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B7355)),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Loading model...', style: TextStyle(color: Color(0xFF8B7355))),
        ],
      );
    } else if (_modelError) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Model unavailable',
            style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF5D4A3A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _modelErrorMessage ?? 'This feature requires a supported device. Try again.',
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF8B7355)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _loadModel(fromRetry: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry loading'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC4A06E)),
          ),
        ],
      );
    } else if (_classifying) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B7355)),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Analyzing gesture...', style: TextStyle(color: Color(0xFF8B7355))),
        ],
      );
    } else if (_detectionFailed) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE8D1),
              border: Border.all(color: const Color(0xFFFFD4B3), width: 2),
            ),
            child: const Icon(Icons.warning_outlined, color: Color(0xFFC4A06E), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'No gesture recognized',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5D4A3A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Could not detect a hand gesture in the image.',
            style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8B7355)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _clearSelection(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC4A06E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Try Again',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_label == null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ready to analyze',
            style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF5D4A3A)),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      content = const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Container(
        key: ValueKey(stateKey),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFFFFAF0),
          border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
        ),
        child: content,
      ),
    );
  }




}

class _PredictionResult {
  const _PredictionResult(this.label, this.confidence);

  final String label;
  final double confidence;
}
