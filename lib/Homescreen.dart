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

  String _simulationResult = "";
  List<Map<String, dynamic>> tableData = [];
  List<int> interArrivals = [];

  void _runSimulation(String simulationType) {
    setState(() {
      // Generate data for the simulation
      interArrivals = generateTimes(100, _arrivalDistributionChoice,
          double.tryParse(_meanController.text) ?? 5.0, double.tryParse(_stdDevController.text) ?? 1.0);

      List<int> serviceTimes = generateTimes(100, _serviceDistributionChoice,
          double.tryParse(_meanController.text) ?? 5.0, double.tryParse(_stdDevController.text) ?? 1.0);

      // Populate table data
      tableData = List.generate(interArrivals.length, (index) {
        return {
          'Customer': index + 1,
          'Arrival Time': interArrivals[index],
          'Service Time': serviceTimes[index],
        };
      });

      // Run the simulation logic
      _simulationResult = runSimulation(
        simulationType: simulationType,
        endTime: int.tryParse(_endTimeController.text) ?? 100,
        arrivalDistributionChoice: _arrivalDistributionChoice,
        serviceDistributionChoice: _serviceDistributionChoice,
        mean: double.tryParse(_meanController.text) ?? 5.0,
        stdDev: double.tryParse(_stdDevController.text) ?? 1.0,
        numServers: int.tryParse(_numServersController.text) ?? 1,
      );
    });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => setState(() => _arrivalDistributionChoice = 1), child: const Text('Exponential')),
                  ElevatedButton(onPressed: () => setState(() => _arrivalDistributionChoice = 2), child: const Text('Normal')),
                  ElevatedButton(onPressed: () => setState(() => _arrivalDistributionChoice = 3), child: const Text('Gamma')),
                  ElevatedButton(onPressed: () => setState(() => _arrivalDistributionChoice = 4), child: const Text('Uniform')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Service Distribution:',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => setState(() => _serviceDistributionChoice = 1), child: const Text('Exponential')),
                  ElevatedButton(onPressed: () => setState(() => _serviceDistributionChoice = 2), child: const Text('Normal')),
                  ElevatedButton(onPressed: () => setState(() => _serviceDistributionChoice = 3), child: const Text('Gamma')),
                  ElevatedButton(onPressed: () => setState(() => _serviceDistributionChoice = 4), child: const Text('Uniform')),
                ],
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
              const Text(
                'Simulation Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_simulationResult, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Text(
                'Data Table:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Arrival Time')),
                  DataColumn(label: Text('Service Time')),
                ],
                rows: tableData
                    .map(
                      (row) => DataRow(cells: [
                        DataCell(Text(row['Customer'].toString())),
                        DataCell(Text(row['Arrival Time'].toString())),
                        DataCell(Text(row['Service Time'].toString())),
                      ]),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
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
