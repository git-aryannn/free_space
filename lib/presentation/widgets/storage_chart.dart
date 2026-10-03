import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:free_space/data/repositories/storage_repository.dart';
import 'package:free_space/core/utils/file_utils.dart';

/// A widget that displays storage usage in a visually appealing pie chart.
class StorageChart extends StatefulWidget {
  /// The storage information to display.
  final StorageInfo storageInfo;

  const StorageChart({super.key, required this.storageInfo});

  @override
  State<StorageChart> createState() => _StorageChartState();
}

class _StorageChartState extends State<StorageChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final freeColor = theme.brightness == Brightness.dark
        ? const Color(0xFF465160)
        : const Color(0xFFE6E1D7);

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    sections: _buildSections(
                      usedColor: colorScheme.primary,
                      freeColor: freeColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FileUtils.formatFileSize(widget.storageInfo.usedBytes),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'of',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      FileUtils.formatFileSize(widget.storageInfo.totalBytes),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: colorScheme.primary,
                text: 'Used',
                textColor: colorScheme.onSurface,
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                color: freeColor,
                text: 'Free',
                textColor: colorScheme.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections({
    required Color usedColor,
    required Color freeColor,
  }) {
    final double usedPct = widget.storageInfo.totalBytes > 0
        ? (widget.storageInfo.usedBytes / widget.storageInfo.totalBytes)
            .clamp(0.0, 1.0)
        : 0;
    final double freePct = 1 - usedPct;

    return [
      PieChartSectionData(
        color: usedColor,
        value: usedPct * 100,
        title: '',
        radius: _touchedIndex == 0 ? 30.0 : 20.0,
      ),
      PieChartSectionData(
        color: freeColor,
        value: freePct * 100,
        title: '',
        radius: _touchedIndex == 1 ? 30.0 : 20.0,
      ),
    ];
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
