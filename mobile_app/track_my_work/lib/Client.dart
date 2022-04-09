import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';

import 'package:track_my_work/models/User.dart';

class Client {

  Future<void> updateGoalIntervalLengthForProject(String userId, int projectNumber, int hour, int minutes) async {
    print(projectNumber);
    print(hour);
    print(minutes);
    print(userId);
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateGoalIntervalLengthForProject');
    final results = await callable.call(<String, dynamic>{
      'id': userId,
      'selectedProjectNumber': projectNumber,
      'hours': hour,
      'minutes': minutes,
    });
    print(results.data);
    return;
  }

  Future<void> updateStatus(String userId, bool atDesk) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('update');
    final results = await callable.call(<String, dynamic>{
      'id': userId,
      'atDesk': atDesk
    });
    print(results.data);
    return;
  }

  Future<void> updateAtDesk(bool atDesk, String userId) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateAtDesk');
    final results = await callable.call(<String, dynamic>{
      'id': userId,
      'atDesk': atDesk
    });
    print(results.data);
    return;
  }

  Future<void> updateCurrentWorkingProject(int projectNumber, String userId) async {
    print(projectNumber);
    print(userId);
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateCurrentWorkingProject');
    final results = await callable.call(<String, dynamic>{
      'id': userId,
      'selectedProjectNumber': projectNumber
    });
    print(results.data);
    return;
  }

  Future<void> updateProjectName(String name, int projectNumber, String userId) async {
    print(projectNumber);
    print(userId);
    print(name);
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateProjectName');
    final results = await callable.call(<String, dynamic>{
      'id': userId,
      'selectedProjectNumber': projectNumber,
      'name': name
    });
    print(results.data);
    return;
  }

  Future<void> takeABreak() async {
    Timer(const Duration(seconds: 1), () {

    });
    return;
  }

  Future<Map<String, dynamic>> getUser() async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getUser');
    final results = await callable();
    print(results.data);
    return Map.from(results.data);
  }
}