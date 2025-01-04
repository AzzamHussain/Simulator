// simulation/simulator.dart
import '../models/customer.dart';
import 'dart:math';

// Check if service can proceed
bool checkShouldServiceProceed(List<Customer> customerList) {
  return customerList.any((customer) => customer.timeLeft > 0);
}

// Serve customers based on highest priority
String serveHighestPriorityFirst(List<Customer> customers, int numServers,
    {bool preemptive = true}) {
  List<Server> servers = List.generate(numServers, (i) => Server(serverId: i));
  int timePassed = 0;

  while (checkShouldServiceProceed(customers)) {
    List<Customer> readyQueue = customers
        .where((customer) =>
            customer.arrivalTime <= timePassed && customer.timeLeft > 0)
        .toList();

    readyQueue.sort((a, b) => a.priority.compareTo(b.priority));

    if (preemptive) {
      for (var server in servers) {
        if (server.currentCustomer != null && readyQueue.isNotEmpty) {
          int highestPriorityWaiting = readyQueue.first.priority;
          if (highestPriorityWaiting < server.currentCustomer!.priority) {
            Customer currentCustomer = server.currentCustomer!;
            currentCustomer.appendEndTimes(timePassed);
            currentCustomer.serverId = null;
            server.currentCustomer = null;
            readyQueue.add(currentCustomer);
            readyQueue.sort((a, b) => a.priority.compareTo(b.priority));
          }
        }
      }
    }

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

    servers.where((server) => server.currentCustomer != null).forEach((server) {
      Customer current = server.currentCustomer!;
      current.decrementTimeLeft();
      if (current.timeLeft == 0) {
        current.setEndTime(timePassed + 1);
        current.setCompletionTime(timePassed + 1);
        current.setTurnAroundTime();
        current.setWaitTime();
        current.setUtilizationTime();
        current.appendEndTimes(timePassed + 1);
        server.currentCustomer = null;
      }
    });

    timePassed++;
  }

  return "Simulation Completed: Priority-Based Scheduling";
}

// Serve customers based on First-Come-First-Serve
String serveFirstComeFirstServe(List<Customer> customers, int numServers) {
  List<Server> servers = List.generate(numServers, (i) => Server(serverId: i));
  int timePassed = 0;

  while (checkShouldServiceProceed(customers)) {
    List<Customer> readyQueue = customers
        .where((customer) =>
            customer.arrivalTime <= timePassed && customer.timeLeft > 0)
        .toList();

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

    servers.where((server) => server.currentCustomer != null).forEach((server) {
      Customer current = server.currentCustomer!;
      current.decrementTimeLeft();
      if (current.timeLeft == 0) {
        current.setEndTime(timePassed + 1);
        current.setCompletionTime(timePassed + 1);
        current.setTurnAroundTime();
        current.setWaitTime();
        current.setUtilizationTime();
        current.appendEndTimes(timePassed + 1);
        server.currentCustomer = null;
      }
    });

    timePassed++;
  }

  return "Simulation Completed: FCFS Scheduling";
}

// Generate random times based on chosen distribution
List<int> generateTimes(
    int count, int distributionChoice, double mean, double stdDev) {
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
        times.add((mean + z * stdDev).round());
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
        times.add((random.nextDouble() * (mean + stdDev - (mean - stdDev)) +
                (mean - stdDev))
            .round());
        break;
      default:
        times.add(mean.round()); // Default to mean
        break;
    }
  }

  return times;
}

// Run the simulation with tables
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
  List<int> arrivalTimes =
      generateTimes(100, arrivalDistributionChoice, mean, stdDev);
  List<int> serviceTimes = generateTimes(
      arrivalTimes.length, serviceDistributionChoice, mean, stdDev);

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

  if (simulationType == "1") {
    serveHighestPriorityFirst(customers, numServers);
  } else {
    serveFirstComeFirstServe(customers, numServers);
  }

  // Customer Details Table
  List<Map<String, dynamic>> customerDetails = customers
      .map((c) => {
            "S.No": c.customerId,
            "Inter Arrivals": c.interArrival,
            "Arrival Time": c.arrivalTime,
            "Service Time": c.burstTime,
            "Priorities": c.priority,
          })
      .toList();

  // Final Customer Table
  List<Map<String, dynamic>> finalCustomerTable = customers
      .map((c) => {
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
          })
      .toList();

  // Average Metrics Table
  Map<String, dynamic> avgMetrics = {
    "Avg Turn Around Time":
        customers.map((c) => c.turnAroundTime).reduce((a, b) => a + b) /
            customers.length,
    "Avg Wait Time": customers.map((c) => c.waitTime).reduce((a, b) => a + b) /
        customers.length,
    "Avg Response Time":
        customers.map((c) => c.responseTime).reduce((a, b) => a + b) /
            customers.length,
  };

  List<Map<String, dynamic>> averageMetrics = avgMetrics.entries
      .map((e) => {"Metric": e.key, "Value": e.value})
      .toList();

  // Average Metrics by Priority Table
  Map<int, List<Customer>> customersByPriority = {};
  customers.forEach((c) {
    customersByPriority.putIfAbsent(c.priority, () => []).add(c);
  });

  List<Map<String, dynamic>> averageMetricsByPriority =
      customersByPriority.entries.map((entry) {
    int priority = entry.key;
    List<Customer> priorityCustomers = entry.value;

    return {
      "Priority": priority,
      "Avg InterArrival Time":
          priorityCustomers.map((c) => c.interArrival).reduce((a, b) => a + b) /
              priorityCustomers.length,
      "Avg Service Time":
          priorityCustomers.map((c) => c.burstTime).reduce((a, b) => a + b) /
              priorityCustomers.length,
      "Avg Completion Time":
          priorityCustomers.map((c) => c.endTime).reduce((a, b) => a + b) /
              priorityCustomers.length,
      "Avg Turn Around Time": priorityCustomers
              .map((c) => c.turnAroundTime)
              .reduce((a, b) => a + b) /
          priorityCustomers.length,
      "Avg Wait Time":
          priorityCustomers.map((c) => c.waitTime).reduce((a, b) => a + b) /
              priorityCustomers.length,
      "Avg Response Time":
          priorityCustomers.map((c) => c.responseTime).reduce((a, b) => a + b) /
              priorityCustomers.length,
    };
  }).toList();

  // Server Utilization Table
  List<Map<String, dynamic>> serverUtilization = [];

  Map<int, List<Customer>> customersByServer = {};
  for (var customer in customers) {
    if (customer.serverId != null) {
      customersByServer.putIfAbsent(customer.serverId!, () => []).add(customer);
    }
  }

  customersByServer.forEach((serverId, serverCustomers) {
    double totalServiceTime = serverCustomers
        .map((c) => c.burstTime)
        .reduce((a, b) => a + b)
        .toDouble();
    double utilization = totalServiceTime / endTime;

    serverUtilization.add({
      "Server ID": serverId,
      "Utilization": "${(utilization * 100).toStringAsFixed(2)}%"
    });
  });

// Average Queuing Metrics Table
Map<String, dynamic> avgQueueMetrics = {
  "Avg Queue Length": customers
      .where((c) => c.waitTime > 0)
      .map((c) => c.waitTime)
      .reduce((a, b) => a + b)
      .toDouble() /
      customers.length,
  "Avg Waiting Time in Queue": customers
      .map((c) => c.waitTime)
      .reduce((a, b) => a + b)
      .toDouble() /
      customers.length,
};

List<Map<String, dynamic>> averageQueuingMetrics = avgQueueMetrics.entries
    .map((entry) => {"Metric": entry.key, "Value": entry.value.toStringAsFixed(2)})
    .toList();

// Add to the returned tables
return {
  "customerDetails": customerDetails,
  "finalCustomerTable": finalCustomerTable,
  "averageMetrics": averageMetrics,
  "averageMetricsByPriority": averageMetricsByPriority,
  "serverUtilization": serverUtilization,
  "averageQueuingMetrics": averageQueuingMetrics,
};

}
