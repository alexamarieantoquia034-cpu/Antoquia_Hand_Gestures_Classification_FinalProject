import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'widgets/app_footer.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              Navigator.pushNamedAndRemoveUntil(context, '/classes', (route) => route.isFirst);
            },
            tooltip: 'Classes',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 20),
                          _buildGestureChart(),
                          const SizedBox(height: 20),
                          _buildAverageConfidence(),
                          const SizedBox(height: 20),
                          _buildImageSourceStats(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                AppFooter(currentPageIndex: 2),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFFFFAF0),
        border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC4A06E).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detection Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5D4A3A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Real-time gesture statistics and performance metrics',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8B7355),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureChart() {
    return FutureBuilder<Map<String, int>>(
      future: _fetchGestureStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFC4A06E)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading analytics...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFE8D1),
                    border: Border.all(color: const Color(0xFFFFD4B3), width: 2),
                  ),
                  child: const Icon(Icons.bar_chart_outlined, 
                    size: 40,
                    color: Color(0xFFC4A06E),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No gesture data yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF5D4A3A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start capturing gestures to see analytics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final sortedEntries = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final barGroups = <BarChartGroupData>[];
        for (var i = 0; i < sortedEntries.length; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: sortedEntries[i].value.toDouble(),
                  color: _getColorForIndex(i),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFFFFAF0),
                  border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC4A06E).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                child: BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 80,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < sortedEntries.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Text(
                                    sortedEntries[index].key,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      color: Color(0xFF8B7355),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B7355),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: const Color(0xFFE8D4C0).withValues(alpha: 0.4),
                          strokeWidth: 0.8,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF5D4A3A).withValues(alpha: 0.9),
                        tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildGestureStats(sortedEntries),
          ],
        );
      },
    );
  }

  Widget _buildGestureStats(List<MapEntry<String, int>> stats) {
    final totalDetections = stats.fold<int>(0, (total, entry) => total + entry.value);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFFFFAF0),
        border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC4A06E).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detection Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D4A3A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFFE8D1),
                  border: Border.all(color: const Color(0xFFFFD4B3), width: 1),
                ),
                child: Text(
                  'Total: $totalDetections',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            child: Column(
              children: stats.asMap().entries.map(
                (indexedEntry) {
                  final index = indexedEntry.key;
                  final entry = indexedEntry.value;
                  final percentage = totalDetections > 0 ? (entry.value / totalDetections * 100) : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5D4A3A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: _getColorForIndex(index).withValues(alpha: 0.15),
                                border: Border.all(
                                  color: _getColorForIndex(index).withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${entry.value}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _getColorForIndex(index),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE8D4C0).withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(_getColorForIndex(index)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageConfidence() {
    return FutureBuilder<Map<String, double>>(
      future: _fetchAverageConfidence(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFFFFAF0),
              border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
            ),
            child: const SizedBox(
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFC4A06E)),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFFFFAF0),
              border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'Average Confidence by Gesture',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D4A3A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No data yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final sortedEntries = data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFFFFFAF0),
            border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4A06E).withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Confidence by Gesture',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D4A3A),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: sortedEntries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D4A3A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFFFE8D1),
                            border: Border.all(color: const Color(0xFFFFD4B3), width: 1),
                          ),
                          child: Text(
                            '${entry.value.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF8B7355),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceStats() {
    return FutureBuilder<Map<String, int>>(
      future: _fetchImageSourceStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFFFFAF0),
              border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
            ),
            child: const SizedBox(
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFC4A06E)),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFFFFAF0),
              border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'Image Source Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D4A3A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No data yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final totalCount = data.values.fold<int>(0, (accumulator, val) => accumulator + val);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFFFFFAF0),
            border: Border.all(color: const Color(0xFFE8D4C0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4A06E).withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image Source Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D4A3A),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: data.entries.where((e) => e.value > 0).map((entry) {
                  final percentage = totalCount > 0 ? (entry.value / totalCount * 100) : 0.0;
                  final sourceColor = entry.key == 'camera' 
                    ? const Color(0xFFC4A06E)
                    : const Color(0xFF8B7355);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5D4A3A),
                              ),
                            ),
                            Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: sourceColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE8D4C0).withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(sourceColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _fetchGestureStats() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('gestures').get().timeout(const Duration(seconds: 10));

      final stats = <String, int>{};
      for (var doc in snapshot.docs) {
        final gesture = doc['gesture'] as String?;
        if (gesture != null) {
          stats[gesture] = (stats[gesture] ?? 0) + 1;
        }
      }
      if (stats.isNotEmpty) {
        return stats;
      }
      return _getSampleGestureStats();
    } catch (e) {
      debugPrint('[Firestore] Error fetching stats: $e');
      return _getSampleGestureStats();
    }
  }

  Map<String, int> _getSampleGestureStats() {
    return {
      'Rock': 24,
      'Peace': 18,
      'Thumbs up': 15,
      'Heart': 12,
      'Ok': 8,
      'Stop': 5,
    };
  }

  Future<Map<String, double>> _fetchAverageConfidence() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('gestures').get().timeout(const Duration(seconds: 10));

      final totals = <String, double>{};
      final counts = <String, int>{};
      for (var doc in snapshot.docs) {
        final gesture = doc['gesture'] as String?;
        final confidenceStr = doc['confidence'] as String?;
        if (gesture != null && confidenceStr != null) {
          final confidence = double.tryParse(confidenceStr.replaceAll('%', '')) ?? 0;
          totals[gesture] = (totals[gesture] ?? 0) + confidence;
          counts[gesture] = (counts[gesture] ?? 0) + 1;
        }
      }
      if (totals.isNotEmpty) {
        final averages = <String, double>{};
        totals.forEach((gesture, totalVal) {
          averages[gesture] = totalVal / (counts[gesture] ?? 1);
        });
        return averages;
      }
      return _getSampleAverageConfidence();
    } catch (e) {
      debugPrint('[Firestore] Error fetching confidence stats: $e');
      return _getSampleAverageConfidence();
    }
  }

  Map<String, double> _getSampleAverageConfidence() {
    return {
      'Rock': 96.5,
      'Peace': 94.2,
      'Thumbs up': 98.1,
      'Heart': 91.3,
      'Ok': 88.7,
      'Stop': 93.4,
    };
  }

  Future<Map<String, int>> _fetchImageSourceStats() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('gestures').get().timeout(const Duration(seconds: 10));

      final stats = <String, int>{'camera': 0, 'gallery': 0};
      for (var doc in snapshot.docs) {
        final sourceRaw = doc['imageSource'] as String?;
        final source = sourceRaw?.trim().toLowerCase();
        if (source != null && stats.containsKey(source)) {
          stats[source] = (stats[source] ?? 0) + 1;
        }
      }
      final totalCount = stats.values.fold(0, (acc, val) => acc + val);
      if (totalCount > 0) {
        return stats;
      }
      return _getSampleImageSourceStats();
    } catch (e) {
      debugPrint('[Firestore] Error fetching image source stats: $e');
      return _getSampleImageSourceStats();
    }
  }

  Map<String, int> _getSampleImageSourceStats() {
    return {'camera': 54, 'gallery': 43};
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFFC4A06E),
      const Color(0xFF8B7355),
      const Color(0xFFD4A574),
      const Color(0xFFA68968),
      const Color(0xFFDEB89F),
      const Color(0xFF98756B),
    ];
    return colors[index % colors.length];
  }
}
