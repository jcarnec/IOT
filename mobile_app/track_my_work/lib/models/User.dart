import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:track_my_work/models/Project.dart';
import 'Interval.dart' as Interval;

import 'constants.dart';

class User with ChangeNotifier {
   String id;
   List<Project> projects = [];
   int selectedProjectIndex;
   bool isWorking;
   bool atDesk;

   User(
       {this.id,
      this.projects,
      this.selectedProjectIndex = 3,
       this.isWorking = false, this.atDesk});

  User.fromJson(Map<String, dynamic> json, this.id) {
    List<dynamic> projectsJson = json['projects'];
    for (var element in projectsJson) {
      Map<String, dynamic> jsonProject = Map.from(element);
      projects.add(Project.fromJson(jsonProject));
    }
    selectedProjectIndex = json['selectedProjectNumber'];
    if(selectedProjectIndex > projects.length) {
      selectedProjectIndex = projects.length - 1;
    }
    isWorking = json['isWorking'] ?? false;
    atDesk = json['atDesk'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'projects': projects.map((e) => e.toJson()).toList(),
      'selectedProjectNumber': selectedProjectIndex
    };
    return json;
  }

  void updateUser(User user) {
    id = user.id;
    projects = user.projects;
    selectedProjectIndex = user.selectedProjectIndex;
    isWorking = user.isWorking;
    notifyListeners();
  }

  int getMostTimeSpent() {
    int maxTimeSpent = 0;
    for (var element in projects) {
      if(element.getTotalTimeSpentInSeconds() > maxTimeSpent) {
        maxTimeSpent = element.getTotalTimeSpentInSeconds();
      }
    }
    return maxTimeSpent;
  }

   int getMostTimeSpentOnDate(DateTime dateTime) {
     int maxTimeSpent = 0;
     for (var element in projects) {
       var timeSpent = element.getTotalTimeSpentInSecondsOnDate(dateTime);
       if(timeSpent > maxTimeSpent) {
         maxTimeSpent = element.getTotalTimeSpentInSecondsOnDate(dateTime);
       }
     }
     return maxTimeSpent;
   }

  Duration getTimeSinceLastIntervalForWorkingProject() {
    if(projects[selectedProjectIndex].intervals.isNotEmpty) {
      Interval.Interval mostRecent = projects[selectedProjectIndex].intervals.last;
      if(isWorking) {
        return DateTime.now().difference(mostRecent.startTimeStamp);
      }
      else{
        return DateTime.now().difference(mostRecent.endTimeStamp);
      }
    }
  }

  int getIndexFromProject(Project project) {
    return projects.indexOf(project);
  }

   Color mapProjectIndexToBackgroundColor(int index) {
     switch (index) {
       case 0:
         return project1Bg;
       case 1:
         return project2Bg;
       case 2:
         return project3Bg;
       case 3:
         return project4Bg;
     }
     return Colors.transparent;
   }

   Color mapProjectIndexToForegroundColor(int index) {
     switch (index) {
       case 0:
         return project1Fg;
       case 1:
         return project2Fg;
       case 2:
         return project3Fg;
       case 3:
         return project4Fg;
     }
     return Colors.transparent;
   }
}