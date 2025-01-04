import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:simulator/utils/utils.dart';
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
  List<int> interArrivals = [];

  void _runSimulation(String simulationType) {
    setState(() {
      _simulationResult = runSimulation(
        simulationType: simulationType,
        endTime: int.tryParse(_endTimeController.text) ?? 100,
        arrivalDistributionChoice: _arrivalDistributionChoice,
        serviceDistributionChoice: _serviceDistributionChoice,
        mean: double.tryParse(_meanController.text) ?? 0.0,
        stdDev: double.tryParse(_stdDevController.text) ?? 0.0,
        numServers: int.tryParse(_numServersController.text) ?? 1,
      );

      // Retrieve inter-arrival times for the graph
      interArrivals = getArrivalTimes(_arrivalDistributionChoice, int.tryParse(_endTimeController.text) ?? 100)['interArrivals']!;
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
                  ElevatedButton(
                    onPressed: () => setState(() => _arrivalDistributionChoice = 1),
                    child: const Text('Exponential'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _arrivalDistributionChoice = 2),
                    child: const Text('Normal'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _arrivalDistributionChoice = 3),
                    child: const Text('Gamma'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _arrivalDistributionChoice = 4),
                    child: const Text('Uniform'),
                  ),
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
                  ElevatedButton(
                    onPressed: () => setState(() => _serviceDistributionChoice = 1),
                    child: const Text('Exponential'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _serviceDistributionChoice = 2),
                    child: const Text('Normal'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _serviceDistributionChoice = 3),
                    child: const Text('Gamma'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _serviceDistributionChoice = 4),
                    child: const Text('Uniform'),
                  ),
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
              Text(
                _simulationResult,
                style: const TextStyle(fontSize: 16),
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
