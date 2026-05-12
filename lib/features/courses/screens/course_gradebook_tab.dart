import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CourseGradebookTab extends StatelessWidget {
  const CourseGradebookTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock assignments matching the screenshot data
    final assignments = [
      _GradeItem(
        title: 'Quiz 1: Intro to Law',
        dueDate: 'Due October 28, 2025',
        score: 19,
        maxScore: 20,
        percentage: 99,
        hasScore: true,
      ),
      _GradeItem(
        title: 'Assignment 2: Evidence Law 1',
        dueDate: 'Due October 27, 2025',
        score: 18,
        maxScore: 20,
        percentage: 99,
        hasScore: true,
      ),
      _GradeItem(
        title: 'Assignment 3: Evidence Law 2',
        dueDate: 'Due October 26, 2025',
        score: 0,
        maxScore: 20,
        percentage: 0,
        hasScore: false,
      ),
      _GradeItem(
        title: 'Assignment 3: Evidence Law 2', // Exact text from screenshot
        dueDate: 'Due October 25, 2025',
        score: 0,
        maxScore: 20,
        percentage: 0,
        hasScore: false,
      ),
      _GradeItem(
        title: 'Assignment 4: Evidence Law 3',
        dueDate: 'Due October 24, 2025',
        score: 0,
        maxScore: 20,
        percentage: 0,
        hasScore: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildGradeCard(context, assignments[index]);
      },
    );
  }

  Widget _buildGradeCard(BuildContext context, _GradeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAnalysisSheet(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            item.dueDate,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.hasScore ? '${item.score}/${item.maxScore}' : '-/${item.maxScore}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.bar_chart, size: 20, color: Colors.black),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.hasScore ? '${item.percentage}%' : '--',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: item.hasScore ? Colors.green : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnalysisSheet(BuildContext context, _GradeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // Covers most of the screen
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Analysis',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Score Graph Distribution for ${item.title.split(':').first}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bar Chart
                    SizedBox(
                      height: 200,
                      child: item.hasScore ? _buildBarChart() : _buildEmptyBarChart(),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Pie Chart Distribution for ${item.title.split(':').first}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Total Students label
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Students',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.hasScore ? '200' : '--',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Pie Chart & Legend
                    SizedBox(
                      height: 180,
                      child: item.hasScore ? _buildPieChart() : _buildEmptyPieChart(),
                    ),
                    const SizedBox(height: 48), // Bottom padding
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 400,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.black54, fontSize: 10);
                switch (value.toInt()) {
                  case 0:
                    return const Padding(padding: EdgeInsets.only(top: 8), child: Text('0-50', style: style));
                  case 1:
                    return const Padding(padding: EdgeInsets.only(top: 8), child: Text('51-60', style: style));
                  case 2:
                    return const Padding(padding: EdgeInsets.only(top: 8), child: Text('61-70', style: style));
                  case 3:
                    return const Padding(padding: EdgeInsets.only(top: 8), child: Text('71-80', style: style));
                  case 4:
                    return const Padding(padding: EdgeInsets.only(top: 8), child: Text('81-90', style: style));
                  case 5:
                    return const Padding(padding: EdgeInsets.only(top: 8), child: Text('91-100', style: style));
                  default:
                    return const Text('');
                }
              },
            ),
            axisNameWidget: const Text('Percentage Score', style: TextStyle(color: Colors.black54, fontSize: 10)),
            axisNameSize: 20,
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                );
              },
            ),
            axisNameWidget: const Text('Number of Students', style: TextStyle(color: Colors.black54, fontSize: 10)),
            axisNameSize: 20,
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, 160),
          _makeBarGroup(1, 110),
          _makeBarGroup(2, 220),
          _makeBarGroup(3, 310),
          _makeBarGroup(4, 150),
          _makeBarGroup(5, 70),
        ],
      ),
    );
  }

  Widget _buildEmptyBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 400,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.black54, fontSize: 10);
                switch (value.toInt()) {
                  case 0: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('0-50', style: style));
                  case 1: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('51-60', style: style));
                  case 2: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('61-70', style: style));
                  case 3: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('71-80', style: style));
                  case 4: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('81-90', style: style));
                  case 5: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('91-100', style: style));
                  default: return const Text('');
                }
              },
            ),
            axisNameWidget: const Text('Percentage Score', style: TextStyle(color: Colors.black54, fontSize: 10)),
            axisNameSize: 20,
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                );
              },
            ),
            axisNameWidget: const Text('Number of Students', style: TextStyle(color: Colors.black54, fontSize: 10)),
            axisNameSize: 20,
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, 0),
          _makeBarGroup(1, 0),
          _makeBarGroup(2, 0),
          _makeBarGroup(3, 0),
          _makeBarGroup(4, 0),
          _makeBarGroup(5, 0),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y == 0 ? 5 : y, // Give a tiny bar if 0 so the baseline dashes show nicely or use it safely
          color: y == 0 ? Colors.grey.shade300 : const Color(0xFF0F172A),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 10,
              sections: [
                PieChartSectionData(
                  color: Colors.blue.shade400,
                  value: 32,
                  title: '32%',
                  radius: 70,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: 15.4,
                  title: '15.4%',
                  radius: 70,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.orange.shade600,
                  value: 8.0,
                  title: '8.0%',
                  radius: 70,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: const Color(0xFF00BFA5), // Teal-ish
                  value: 14.3,
                  title: '14.3%',
                  radius: 70,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: 15,
                  title: '15%',
                  radius: 70,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: const Color(0xFF39FF14), // bright green
                  value: 32,
                  title: '32%', // Matching screenshot's slightly off numbers
                  radius: 70,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem(Colors.red.shade300, '91-100'),
            _legendItem(Colors.green.shade800, '81-90'),
            _legendItem(Colors.blue.shade400, '71-80'),
            _legendItem(Colors.greenAccent.shade400, '61-70'),
            _legendItem(Colors.red, '51-60'),
            _legendItem(Colors.red.shade700, '0-50'),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyPieChart() {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                  color: Colors.grey.shade600,
                  value: 100,
                  title: 'No Distribution',
                  radius: 80,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendItem(Colors.red.shade300, '91-100'),
            _legendItem(Colors.green.shade800, '81-90'),
            _legendItem(Colors.blue.shade400, '71-80'),
            _legendItem(Colors.greenAccent.shade400, '61-70'),
            _legendItem(Colors.red, '51-60'),
            _legendItem(Colors.red.shade700, '0-50'),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _GradeItem {
  final String title;
  final String dueDate;
  final int score;
  final int maxScore;
  final int percentage;
  final bool hasScore;

  const _GradeItem({
    required this.title,
    required this.dueDate,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.hasScore,
  });
}
