// simulation/simulator.dart
import '../models/customer.dart';
import 'dart:math';

// Check if service can proceed
bool checkShouldServiceProceed(List<Customer> customerList) {
  return customerList.any((customer) => customer.timeLeft > 0);
}

// Serve customers based on highest priority
String serveHighestPriorityFirst(List<Customer> customers, int numServers, {bool preemptive = true}) {
  List<Server> servers = List.generate(numServers, (i) => Server(serverId: i));
  int timePassed = 0;

  while (checkShouldServiceProceed(customers)) {
    List<Customer> readyQueue = customers
        .where((customer) => customer.arrivalTime <= timePassed && customer.timeLeft > 0)
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
        .where((customer) => customer.arrivalTime <= timePassed && customer.timeLeft > 0)
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
        times.add((random.nextDouble() * (mean + stdDev - (mean - stdDev)) + (mean - stdDev)).round());
        break;
      default:
        times.add(mean.round()); // Default to mean
        break;
    }
  }

  return times;
}

// Run the simulation based on user choices
String runSimulation({
  required String simulationType,
  required int endTime,
  required int arrivalDistributionChoice,
  required int serviceDistributionChoice,
  required double mean,
  required double stdDev,
  required int numServers,
}) {
  StringBuffer result = StringBuffer();

  // Generate arrival and service times
  List<int> arrivalTimes = generateTimes(100, arrivalDistributionChoice, mean, stdDev);
  List<int> serviceTimes = generateTimes(arrivalTimes.length, serviceDistributionChoice, mean, stdDev);

  result.writeln("Simulation Type: ${simulationType == "1" ? "Priority-Based" : "First-Come-First-Serve"}");
  result.writeln("End Time: $endTime");
  result.writeln("Number of Servers: $numServers");
  result.writeln("Arrival Times: $arrivalTimes");
  result.writeln("Service Times: $serviceTimes");

  if (simulationType == "1") {
    List<int> priorities = List.generate(arrivalTimes.length, (index) => Random().nextInt(10));
    result.writeln("Priorities: $priorities");

    List<Customer> customers = List.generate(
      arrivalTimes.length,
      (i) => Customer(
        customerId: i + 1,
        arrivalTime: arrivalTimes[i],
        burstTime: serviceTimes[i],
        priority: priorities[i],
        interArrival: arrivalTimes[i],
      ),
    );

    String simulationResult = serveHighestPriorityFirst(customers, numServers);
    result.writeln(simulationResult);
  } else {
    List<Customer> customers = List.generate(
      arrivalTimes.length,
      (i) => Customer(
        customerId: i + 1,
        arrivalTime: arrivalTimes[i],
        burstTime: serviceTimes[i],
        priority: 0,
        interArrival: arrivalTimes[i],
      ),
    );

    String simulationResult = serveFirstComeFirstServe(customers, numServers);
    result.writeln(simulationResult);
  }

  return result.toString();
}
