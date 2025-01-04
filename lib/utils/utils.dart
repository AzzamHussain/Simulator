// utils/helpers.dart
import 'dart:math';

/// Generates a list of priorities for customers.
List<int> getPriorities(int length) {
  Random random = Random();
  return List.generate(length, (index) => random.nextInt(10));
}

/// Generates arrival times and inter-arrival times based on distribution choice.
Map<String, List<int>> getArrivalTimes(int choice, int endTime) {
  List<int> interArrivals = [0];
  List<int> arrivalTimes = [0];

  int currentTime = 0;
  Random random = Random();

  while (true) {
    int interArrival = random.nextInt(5) + 1; // Example logic for inter-arrival time
    if (currentTime + interArrival > endTime) break;
    interArrivals.add(interArrival);
    currentTime += interArrival;
    arrivalTimes.add(currentTime);
  }

  return {
    'interArrivals': interArrivals,
    'arrivalTimes': arrivalTimes,
  };
}

/// Generates service times for customers based on a given length.
List<int> getServiceTimes(int length, int choice) {
  Random random = Random();
  return List.generate(length, (index) => random.nextInt(5) + 1); // Example logic for service time
}
