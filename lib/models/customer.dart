class Customer {
  final int customerId;
  final int arrivalTime;
  final int burstTime;
  final int priority;
  final int interArrival;
  int timeLeft;
  int? serverId;
  bool isReady = false;
  int startTime = 0;
  int endTime = 0;
  int turnAroundTime = 0;
  int waitTime = 0;
  int responseTime = 0;
  final List<int> startTimes = [];
  final List<int> endTimes = [];

  Customer({
    required this.customerId,
    required this.arrivalTime,
    required this.burstTime,
    required this.priority,
    required this.interArrival,
  }) : timeLeft = burstTime;

  void decrementTimeLeft() {
    if (timeLeft > 0) timeLeft--;
  }

  void setStartTime(int time) => startTime = time;
  void setEndTime(int time) => endTime = time;
  void setTurnAroundTime() => turnAroundTime = endTime - arrivalTime;
  void setWaitTime() => waitTime = turnAroundTime - burstTime;
  void setResponseTime(int time) => responseTime = time - arrivalTime;
  void appendStartTimes(int time) => startTimes.add(time);
  void appendEndTimes(int time) => endTimes.add(time);
}


class Server {
  int serverId;
  Customer? currentCustomer;
  int endTime;

  Server({required this.serverId}) : currentCustomer = null, endTime = 0;
}
