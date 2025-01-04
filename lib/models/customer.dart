// models/customer.dart

class Customer {
  int customerId;
  int arrivalTime;
  int burstTime;
  int priority;
  int timeLeft;
  int? serverId;
  bool isReady;
  int startTime;
  int endTime;
  int completionTime;
  int turnAroundTime;
  int interArrival;
  int waitTime;
  int responseTime;
  double utilizationTime;
  double responseRatio;
  List<int> startTimes;
  List<int> endTimes;

  Customer({
    required this.customerId,
    required this.arrivalTime,
    required this.burstTime,
    required this.priority,
    required this.interArrival,
  })  : timeLeft = burstTime,
        serverId = null,
        isReady = false,
        startTime = 0,
        endTime = 0,
        completionTime = 0,
        turnAroundTime = 0,
        waitTime = 0,
        responseTime = 0,
        utilizationTime = 0.0,
        responseRatio = 0.0,
        startTimes = [],
        endTimes = [];

  void decrementTimeLeft() {
    timeLeft -= 1;
  }

  void setStartTime(int timePassed) {
    startTime = timePassed;
  }

  void setEndTime(int timePassed) {
    endTime = timePassed;
  }

  void setCompletionTime(int timePassed) {
    completionTime = timePassed;
  }

  void setTurnAroundTime() {
    turnAroundTime = completionTime - arrivalTime;
  }

  void setWaitTime() {
    waitTime = turnAroundTime - burstTime;
  }

  void setResponseTime(int timePassed) {
    responseTime = timePassed - arrivalTime;
  }

  void setUtilizationTime() {
    utilizationTime = burstTime / turnAroundTime;
  }

  void appendStartTimes(int timePassed) {
    startTimes.add(timePassed);
  }

  void appendEndTimes(int timePassed) {
    endTimes.add(timePassed);
  }

  void setResponseRatio(int timePassed) {
    responseRatio = ((timePassed - arrivalTime) + burstTime) / burstTime;
  }
}

class Server {
  int serverId;
  Customer? currentCustomer;
  int endTime;

  Server({required this.serverId}) : currentCustomer = null, endTime = 0;
}
