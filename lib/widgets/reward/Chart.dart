import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wasteexpert/models/Reward/RewardModel.dart';
import 'Indicator.dart';

class PieChartSample2 extends StatefulWidget {
  final List<Reward> rewards;
  const PieChartSample2({super.key, required this.rewards});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final wasteData = _calculateWastePercentages();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Waste Type Analysis",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          AspectRatio(
            aspectRatio: 1.5,
            child: Row(
              children: <Widget>[
                const SizedBox(height: 18),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: showingSections(wasteData),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: wasteData.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Indicator(
                        color: _getColorForWasteType(entry.key),
                        text: entry.key,
                        isSquare: true,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateWastePercentages() {
    Map<String, int> wasteCounts = {};
    int totalWaste = 0;

    for (var reward in widget.rewards) {
      for (var waste in reward.wasteList) {
        wasteCounts[waste.wastetype] =
            (wasteCounts[waste.wastetype] ?? 0) + waste.quantity;
        totalWaste += waste.quantity;
      }
    }

    Map<String, double> percentages = {};
    wasteCounts.forEach((type, count) {
      percentages[type] = (count / totalWaste) * 100;
    });

    return percentages;
  }

  List<PieChartSectionData> showingSections(Map<String, double> wasteData) {
    return wasteData.entries.map((entry) {
      final isTouched =
          wasteData.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: _getColorForWasteType(entry.key),
        value: entry.value,
        title: '${entry.value.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }

  Color _getColorForWasteType(String type) {
    switch (type.toLowerCase()) {
      case 'glass':
        return Colors.orange;
      case 'paper':
        return Colors.brown;
      case 'metal':
        return Colors.yellow;
      case 'organic':
        return Colors.green;
      case 'plastic':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
