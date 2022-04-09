class Interval {
   DateTime startTimeStamp;
   DateTime endTimeStamp;

   Interval({this.startTimeStamp, this.endTimeStamp});

  Interval.fromJson(Map<String, dynamic> json) {
    String endTimeString = json['endTimeStamp'];
    if(endTimeString != null) {
      endTimeStamp = DateTime.tryParse(json['endTimeStamp']);
    }
    String startTimeString = json['startTimeStamp'];
    if(startTimeString != null) {
      startTimeStamp = DateTime.tryParse(json['startTimeStamp']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'startTimeStamp': startTimeStamp.toIso8601String(),
      'endTimeStamp': endTimeStamp
    };
    return json;
  }

  DateTime getStartTime() {
     return startTimeStamp;
  }

  DateTime getEndTime() {
     return endTimeStamp ?? DateTime.now();
  }

  int intervalInSeconds() {
     if(endTimeStamp == null) {
       return DateTime.now().difference(startTimeStamp).inSeconds;
     }
    return endTimeStamp.difference(startTimeStamp).inSeconds;
  }
}