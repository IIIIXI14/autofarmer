import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_history_model.dart';

class SensorHistoryScreen extends StatefulWidget {
  final String deviceId;

  const SensorHistoryScreen({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<SensorHistoryScreen> createState() => _SensorHistoryScreenState();
}

class _SensorHistoryScreenState extends State<SensorHistoryScreen> {
  List<SensorHistoryModel> _historyData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    FirebaseFirestore.instance
        .collection('sensors_data_history')
        .doc(widget.deviceId)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        setState(() {
          _historyData = snapshot.docs
              .map((doc) => SensorHistoryModel.fromMap(doc.data()))
              .toList();
          _error = null;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _error = 'Error loading history data: $error';
          _isLoading = false;
        });
      },
    );
  }

  Widget _buildChart(
    String title,
    List<FlSpot> spots,
    Color color,
    String unit,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                  minY: spots.isEmpty ? 0 : spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 5,
                  maxY: spots.isEmpty ? 100 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5,
                ),
              ),
            ),
            if (spots.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Current: ${spots.first.y.toStringAsFixed(1)}$unit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Average: ${(spots.map((e) => e.y).reduce((a, b) => a + b) / spots.length).toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<SensorHistoryModel> data, String type) {
    return data.map((reading) {
      final x = reading.timestamp.millisecondsSinceEpoch.toDouble();
      final y = switch (type) {
        'temperature' => reading.temperature,
        'humidity' => reading.humidity,
        'soilMoisture' => reading.soilMoisture,
        _ => 0.0,
      };
      return FlSpot(x, y);
    }).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _setupListener();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _isLoading = true);
                    _setupListener();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildChart(
                          'Temperature History',
                          _getSpots(_historyData, 'temperature'),
                          Colors.red,
                          '°C',
                        ),
                        const SizedBox(height: 16),
                        _buildChart(
                          'Humidity History',
                          _getSpots(_historyData, 'humidity'),
                          Colors.blue,
                          '%',
                        ),
                        const SizedBox(height: 16),
                        _buildChart(
                          'Soil Moisture History',
                          _getSpots(_historyData, 'soilMoisture'),
                          Colors.green,
                          '%',
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
} 