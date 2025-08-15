class EventModel {
  final String event;
  final dynamic value;

  EventModel({
    required this.event,
    this.value,
  });
}

class EVENTS {
  static String OFFLINE = "connectivity:offline";
  static String ONLINE = "connectivity:online";
}
