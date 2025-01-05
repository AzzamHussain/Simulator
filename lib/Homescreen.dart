import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../simulation/simulator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _numServersController = TextEditingController();
  final TextEditingController _meanController = TextEditingController();
  final TextEditingController _stdDevController = TextEditingController();

  int _arrivalDistributionChoice = 1;
  int _serviceDistributionChoice = 1;

  List<Map<String, dynamic>> customerDetails = [];
  List<Map<String, dynamic>> finalCustomerTable = [];
  List<Map<String, dynamic>> averageMetrics = [];
  List<Map<String, dynamic>> averageMetricsByPriority = [];
  List<Map<String, dynamic>> serverUtilization = [];
  List<Map<String, dynamic>> averageQueuingMetrics = [];
  List<int> interArrivals = [];

  void _runSimulation(String simulationType) {
    setState(() {
      final tables = runSimulationWithTables(
        simulationType: simulationType,
        endTime: int.tryParse(_endTimeController.text) ?? 100,
        arrivalDistributionChoice: _arrivalDistributionChoice,
        serviceDistributionChoice: _serviceDistributionChoice,
        mean: double.tryParse(_meanController.text) ?? 5.0,
        stdDev: double.tryParse(_stdDevController.text) ?? 1.0,
        numServers: int.tryParse(_numServersController.text) ?? 1,
      );

      customerDetails = tables['customerDetails'] ?? [];
      finalCustomerTable = tables['finalCustomerTable'] ?? [];
      averageMetrics = tables['averageMetrics'] ?? [];
      averageMetricsByPriority = tables['averageMetricsByPriority'] ?? [];
      serverUtilization = tables['serverUtilization'] ?? [];
      averageQueuingMetrics = tables['averageQueuingMetrics'] ?? [];
      interArrivals = customerDetails
          .map((row) => row["Inter Arrivals"] as int)
          .where((val) => val >= 0) // Avoid negative values
          .toList();
    });
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> data, List<String> columns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
            rows: data
                .map(
                  (row) => DataRow(
                    cells: columns.map((col) => DataCell(Text(row[col]?.toString() ?? ''))).toList(),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Inter-Arrival Times Histogram:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              barGroups: interArrivals.asMap().entries.map((entry) {
                int key = entry.key;
                int value = entry.value;
                return BarChartGroupData(
                  x: key,
                  barRods: [
                    BarChartRodData(toY: value.toDouble(), color: Colors.blue),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Simulator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Simulation Configuration:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numServersController,
                decoration: const InputDecoration(
                  labelText: 'Number of Servers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Arrival Distribution:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _arrivalDistributionChoice = 1),
                      child: const Text('Exponential'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _arrivalDistributionChoice = 2),
                      child: const Text('Normal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _arrivalDistributionChoice = 3),
                      child: const Text('Gamma'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _arrivalDistributionChoice = 4),
                      child: const Text('Uniform'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _meanController,
                decoration: const InputDecoration(
                  labelText: 'Mean',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _stdDevController,
                decoration: const InputDecoration(
                  labelText: 'Standard Deviation',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _runSimulation("1"),
                child: const Text('Priority-Based Simulation'),
              ),
              ElevatedButton(
                onPressed: () => _runSimulation("2"),
                child: const Text('First-Come-First-Serve Simulation'),
              ),
              const SizedBox(height: 16),
              _buildGraph(),
              _buildTable("Customer Details", customerDetails, ["S.No", "Inter Arrivals", "Arrival Time", "Service Time", "Priorities"]),
              _buildTable("Final Customer Table", finalCustomerTable, [
                "Customer ID",
                "Arrival Time",
                "Service Time",
                "Priority",
                "Start Time",
                "End Time",
                "Turn Around Time",
                "Wait Time",
                "Response Time",
                "Server"
              ]),
              _buildTable("Average Metrics", averageMetrics, ["Metric", "Value"]),
              _buildTable("Average Metrics by Priority", averageMetricsByPriority, [
                "Priority",
                "Avg InterArrival Time",
                "Avg Service Time",
                "Avg Completion Time",
                "Avg Turn Around Time",
                "Avg Wait Time",
                "Avg Response Time"
              ]),
              _buildTable("Server Utilization", serverUtilization, ["Server ID", "Utilization"]),
              _buildTable("Average Queuing Metrics", averageQueuingMetrics, ["Metric", "Value"]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _endTimeController.dispose();
    _numServersController.dispose();
    _meanController.dispose();
    _stdDevController.dispose();
    super.dispose();
  }
}
