import 'dart:math';
import '../models/customer.dart';

/// Checks if there are customers left to be served.
bool checkShouldServiceProceed(List<Customer> customerList) =>
    customerList.any((customer) => customer.timeLeft > 0);

/// Simulates a priority-based scheduling algorithm.
void serveHighestPriorityFirst(List<Customer> customers, int numServers) {
  List<Server> servers = List.generate(numServers, (i) => Server(serverId: i));
  int timePassed = 0;

  while (checkShouldServiceProceed(customers)) {
    // Get customers ready for service
    List<Customer> readyQueue = customers
        .where((customer) =>
            customer.arrivalTime <= timePassed && customer.timeLeft > 0)
        .toList();

    // Sort by priority
    readyQueue.sort((a, b) => a.priority.compareTo(b.priority));

    for (var server in servers) {
      if (server.currentCustomer == null && readyQueue.isNotEmpty) {
        Customer nextCustomer = readyQueue.removeAt(0);
        server.currentCustomer = nextCustomer;
        nextCustomer.serverId = server.serverId;
        if (!nextCustomer.isReady) {
          nextCustomer.setResponseTime(timePassed);
          nextCustomer.setStartTime(timePassed);
          nextCustomer.isReady = true;
        }
        nextCustomer.appendStartTimes(timePassed);
      }
    }

    // Process customers on each server
    servers.where((server) => server.currentCustomer != null).forEach((server) {
      Customer current = server.currentCustomer!;
      current.decrementTimeLeft();
      if (current.timeLeft == 0) {
        current.setEndTime(timePassed + 1);
        current.setTurnAroundTime();
        current.setWaitTime();
        server.currentCustomer = null;
      }
    });

    timePassed++;
  }
}

/// Simulates a First-Come-First-Serve (FCFS) scheduling algorithm.
void serveFirstComeFirstServe(List<Customer> customers, int numServers) {
  List<Server> servers = List.generate(numServers, (i) => Server(serverId: i));
  int timePassed = 0;

  while (checkShouldServiceProceed(customers)) {
    // Get customers ready for service
    List<Customer> readyQueue = customers
        .where((customer) =>
            customer.arrivalTime <= timePassed && customer.timeLeft > 0)
        .toList();

    // Sort by arrival time
    readyQueue.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    for (var server in servers) {
      if (server.currentCustomer == null && readyQueue.isNotEmpty) {
        Customer nextCustomer = readyQueue.removeAt(0);
        server.currentCustomer = nextCustomer;
        nextCustomer.serverId = server.serverId;
        if (!nextCustomer.isReady) {
          nextCustomer.setResponseTime(timePassed);
          nextCustomer.setStartTime(timePassed);
          nextCustomer.isReady = true;
        }
        nextCustomer.appendStartTimes(timePassed);
      }
    }

    // Process customers on each server
    servers.where((server) => server.currentCustomer != null).forEach((server) {
      Customer current = server.currentCustomer!;
      current.decrementTimeLeft();
      if (current.timeLeft == 0) {
        current.setEndTime(timePassed + 1);
        current.setTurnAroundTime();
        current.setWaitTime();
        server.currentCustomer = null;
      }
    });

    timePassed++;
  }
}

/// Generates random times based on a given distribution.
List<int> generateTimes(int count, int distributionChoice, double mean, double stdDev) {
  Random random = Random();
  List<int> times = [];

  for (int i = 0; i < count; i++) {
    switch (distributionChoice) {
      case 1: // Exponential
        times.add((-mean * log(1 - random.nextDouble())).round());
        break;
      case 2: // Normal
        double u1 = random.nextDouble();
        double u2 = random.nextDouble();
        double z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
        times.add((mean + z * stdDev).round().abs());
        break;
      case 3: // Gamma
        double k = mean / stdDev;
        double theta = stdDev;
        double sum = 0;
        for (int j = 0; j < k; j++) {
          sum += -theta * log(1 - random.nextDouble());
        }
        times.add(sum.round());
        break;
      case 4: // Uniform
        times.add((random.nextDouble() * (mean + stdDev - (mean - stdDev)) + (mean - stdDev)).round());
        break;
      default:
        times.add(mean.round());
        break;
    }
  }

  return times;
}

/// Runs the simulation and generates the necessary tables.
Map<String, List<Map<String, dynamic>>> runSimulationWithTables({
  required String simulationType,
  required int endTime,
  required int arrivalDistributionChoice,
  required int serviceDistributionChoice,
  required double mean,
  required double stdDev,
  required int numServers,
}) {
  // Generate arrival and service times
  List<int> arrivalTimes = generateTimes(100, arrivalDistributionChoice, mean, stdDev);
  List<int> serviceTimes = generateTimes(100, serviceDistributionChoice, mean, stdDev);

  // Generate customer list
  List<Customer> customers = List.generate(
    arrivalTimes.length,
    (i) => Customer(
      customerId: i + 1,
      arrivalTime: arrivalTimes[i],
      burstTime: serviceTimes[i],
      priority: simulationType == "1" ? Random().nextInt(10) : 0,
      interArrival: i == 0 ? 0 : arrivalTimes[i] - arrivalTimes[i - 1],
    ),
  );

  // Run simulation
  if (simulationType == "1") {
    serveHighestPriorityFirst(customers, numServers);
  } else {
    serveFirstComeFirstServe(customers, numServers);
  }

  // Customer Details Table
  List<Map<String, dynamic>> customerDetails = customers.map((c) {
    return {
      "S.No": c.customerId,
      "Inter Arrivals": c.interArrival,
      "Arrival Time": c.arrivalTime,
      "Service Time": c.burstTime,
      "Priorities": c.priority,
    };
  }).toList();

  // Final Customer Table
  List<Map<String, dynamic>> finalCustomerTable = customers.map((c) {
    return {
      "Customer ID": c.customerId,
      "Arrival Time": c.arrivalTime,
      "Service Time": c.burstTime,
      "Priority": c.priority,
      "Start Time": c.startTime,
      "End Time": c.endTime,
      "Turn Around Time": c.turnAroundTime,
      "Wait Time": c.waitTime,
      "Response Time": c.responseTime,
      "Server": c.serverId,
    };
  }).toList();

  // Average Metrics Table
  List<Map<String, dynamic>> averageMetrics = [
    {"Metric": "Avg Turn Around Time", "Value": _calculateAverage(customers.map((c) => c.turnAroundTime).toList())},
    {"Metric": "Avg Wait Time", "Value": _calculateAverage(customers.map((c) => c.waitTime).toList())},
    {"Metric": "Avg Response Time", "Value": _calculateAverage(customers.map((c) => c.responseTime).toList())},
  ];

  // Server Utilization Table
  List<Map<String, dynamic>> serverUtilization = List.generate(numServers, (serverId) {
    int busyTime = customers
        .where((c) => c.serverId == serverId)
        .fold(0, (sum, c) => sum + c.burstTime);
    double utilization = (busyTime / endTime) * 100;
    return {"Server ID": serverId, "Utilization": "${utilization.toStringAsFixed(2)}%"};
  });

  // Return all tables
  return {
    "customerDetails": customerDetails,
    "finalCustomerTable": finalCustomerTable,
    "averageMetrics": averageMetrics,
    "serverUtilization": serverUtilization,
  };
}

/// Utility function to calculate average.
double _calculateAverage(List<int> values) {
  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}
