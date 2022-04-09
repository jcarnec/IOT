import 'package:track_my_work/models/Interval.dart';

class Project {
   String name;
   int totalTimeSpentInSeconds;
   List<Interval> intervals = [];
   int goalIntervalLengthInSeconds;
   Map<DateTime, int> totalTimeSpentInSecondsOnDate = {};

   Project({this.name, this.intervals, this.goalIntervalLengthInSeconds, this.totalTimeSpentInSeconds});

  Project.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    goalIntervalLengthInSeconds = json['goalIntervalLengthInSeconds'];
    List<dynamic> intervalsJson = json['intervals'];
    for (var element in intervalsJson) {
      Map<String, dynamic> jsonInterval = Map.from(element);
      intervals.add(Interval.fromJson(jsonInterval));
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'intervals': intervals.map((e) => e.toJson()).toList(),
      'goalIntervalLengthInSeconds': goalIntervalLengthInSeconds
    };
    return json;
  }

  List<Interval> getIntervalsForDate(DateTime dateTime) {
    return intervals.where((element) => element.startTimeStamp.day == dateTime.day && element.startTimeStamp.month == dateTime.month && element.startTimeStamp.year == dateTime.year).toList();
  }

  int getTotalTimeSpentInSeconds() {
    if(totalTimeSpentInSeconds == null) {
      int count = 0;
      for (var element in intervals) {
        count += element.intervalInSeconds();
      }
      totalTimeSpentInSeconds = count;
      print(totalTimeSpentInSeconds);
      return count;
    }
    return totalTimeSpentInSeconds;
  }

   int getTotalTimeSpentInSecondsOnDate(DateTime date) {
     if(totalTimeSpentInSecondsOnDate[date] == null) {
       int count = 0;
       var list = getIntervalsForDate(date);
       for (var element in getIntervalsForDate(date)) {
         count += element.intervalInSeconds();
       }
       totalTimeSpentInSecondsOnDate[date] = count;
       return count;
     } else {
       return totalTimeSpentInSecondsOnDate[date];
     }

   }
}