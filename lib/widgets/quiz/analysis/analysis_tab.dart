import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/analysis/pie_segment.dart';
import '../../../models/analysis/score_distribution_item.dart';
import '../../../models/analysis/score_metric.dart';
import '../../../models/analysis/top_performer.dart';
import '../../../providers/analysis_provider.dart';
import '../../../theme/app_colors.dart';

class AnalysisTab extends StatelessWidget {
  const AnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _buildMetricRow(provider.metrics),
        const SizedBox(height: 24),
        const Text(
          'Score Graph Distribution for Quiz 1',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildBarChart(provider.scoreDistribution),
        const SizedBox(height: 24),
        const Text(
          'Pie Chart Distribution for Quiz 1',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildPieChart(provider.pieSegments),
        const SizedBox(height: 24),
        const Text(
          'Top Performers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...provider.topPerformers.map((performer) => _TopPerformerCard(performer)),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildMetricRow(List<ScoreMetric> metrics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: metrics
          .map(
            (metric) => _MetricCard(
              label: metric.label,
              value: metric.value,
              icon: metric.icon,
              valueColor: metric.color,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBarChart(List<ScoreDistributionItem> data) {
    const tiers = ['0-50', '51-60', '61-70', '71-80', '81-90', '91-100'];
    final maxValue = data.map((item) => item.value).reduce(max);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (index) {
            final value = data[index].value;
            final height = (value / maxValue) * 160;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(tiers[index], style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<PieSegment> segments) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Students 200',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(child: _PieChart(segments: segments)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: segments
                        .map(
                          (segment) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _LegendItem(
                              color: segment.color,
                              label: segment.label,
                              value: '${segment.percent.toStringAsFixed(1)}%',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: valueColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: valueColor)),
          ],
        ),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.segments});

  final List<PieSegment> segments;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(segments),
      child: const AspectRatio(aspectRatio: 1, child: SizedBox()),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter(this.segments);

  final List<PieSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = min(size.width, size.height) / 2;
    var startRadian = -pi / 2;
    for (final segment in segments) {
      final sweepRadian = segment.percent / 100 * 2 * pi;
      paint.color = segment.color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startRadian, sweepRadian, true, paint);
      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TopPerformerCard extends StatelessWidget {
  const _TopPerformerCard(this.performer);

  final TopPerformer performer;

  @override
  Widget build(BuildContext context) {
    final percentage = (performer.score / performer.total * 100).round();
    final color = Colors.primaries[performer.name.length % Colors.primaries.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              performer.name.substring(0, 1),
              style: const TextStyle(color: AppColors.brandWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(performer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(performer.id, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${performer.score}/${performer.total}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('$percentage%', style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
