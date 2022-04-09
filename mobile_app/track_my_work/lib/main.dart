import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:duration_picker_dialog_box/duration_picker_dialog_box.dart';
import 'package:track_my_work/PushNotificationsService.dart';

import 'Client.dart';
import 'firebase_options.dart';

import 'models/Project.dart';
import 'models/User.dart';
import 'models/constants.dart';
import 'package:provider/provider.dart';
import 'models/Interval.dart' as Interval;
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:intl/intl.dart';

void main() async {
  Client client = Client();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String userId = androidInfo.id.replaceAll('.', '');
  userId = 'RKQ1201022002';
  DatabaseReference reference = FirebaseDatabase.instance.ref();
  DatabaseReference userRef = reference.child('users/$userId');
  Map<String, dynamic> json;
  final snapshot = await userRef.get();
  if (snapshot.exists) {
    json = Map.from(snapshot.value);
  } else {
    print('No data available.');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) =>  User.fromJson(json, userId)),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            fontFamily: 'Gilroy',
            primarySwatch: Colors.deepPurple,
            canvasColor: Colors.transparent,
            scaffoldBackgroundColor: Color(0xffebe3ce),

        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User user;
  double panelOpacity = 0;
  PanelController panelController;
  DatabaseReference userDataRef;
  ConfettiController confettiController;
  double percent = 0;
  Duration duration = Duration(seconds: 0);
  String dateString;
  List<Color> confettiColors = [
    project1Bg,
    project2Bg,
    project3Bg,
    project4Bg,
  ];
  ConfettiWidget confettiWidget;

  @override
  void initState() {
    user = Provider.of<User>(context, listen: false);
    userDataRef = FirebaseDatabase.instance.ref('users/${user.id}');
    userDataRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print(data);
      if(data != null) {
        setState(() {
          user.updateUser(User.fromJson(Map.from(data), user.id));
        });
      }


    });
    confettiController = ConfettiController(duration: Duration(milliseconds: 500));
    panelController = PanelController();
    confettiWidget = getConfettiWidget(confettiColors);

    dateString = getDayString(DateTime.now());
    Timer.periodic(Duration(seconds: 10), (Timer t) {});

    FirebaseMessaging fcm = FirebaseMessaging.instance;
    DatabaseReference reference = FirebaseDatabase.instance.ref();
    DatabaseReference userRef = reference.child('users/${user.id}');
    PushNotificationManager(fcm, onNotificationShown, onNotificationShown, () {}).initialise().then((value) async {
      String token = await value.getToken();
      userRef.update({'fcmToken':token});
    });

    super.initState();
  }

  onNotificationShown(RemoteMessage message) {
    showOverlayNotification((context) {
      int projectIndex = int.tryParse(message.data['projectIndex']);
      return Padding(
        padding: const EdgeInsets.only(top: 40, right: 8, left: 8),
        child: Material(
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height * .1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20,),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 45, color: user.mapProjectIndexToForegroundColor(projectIndex),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(message.notification.title, style: TextStyle(fontSize: MediaQuery.of(context).size.width * .04, fontFamily: 'Gilroy', fontWeight: FontWeight.bold, color: user.mapProjectIndexToForegroundColor(projectIndex)),),
                            Text("You've worked for ${_printDuration(Duration(seconds: user.projects[user.selectedProjectIndex].goalIntervalLengthInSeconds))}, well done!", style: TextStyle(
                                fontSize: MediaQuery
                                    .of(context)
                                    .size
                                    .width * .03, fontFamily: 'Gilroy'),),
                            Text(""),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }, duration: Duration(seconds: 7));
  }

  double getPercentageComplete(Duration currentIntervalDuration, int goalInSeconds) {
    if(user.isWorking && goalInSeconds != null && currentIntervalDuration != null) {
      if(currentIntervalDuration.inSeconds >= goalInSeconds) {
        if(percent != 1) {
          setState(() {
            confettiWidget = getConfettiWidget(confettiColors);
          });
          confettiController.play();
        }
        return 1.0;
      }
      else {
        return currentIntervalDuration.inSeconds / goalInSeconds;
      }
    }
    return 0;
  }

  String _printDuration(Duration duration) {
    if(duration != null) {
      String twoDigits(int n) => n.toString().padLeft(0, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
    }
    return '';
  }

  String durationToHours(Duration duration) {
    if(duration != null) {
      String twoDigits(int n) => n.toString().padLeft(0, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return twoDigits(duration.inHours);
    }
    return '';
  }

  String durationToMinutes(Duration duration) {
    if(duration != null) {
      String twoDigits(int n) => n.toString().padLeft(0, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return twoDigitMinutes;
    }
    return '';
  }

  Color getBackgroundColor() {
    if (user.isWorking && percent < 1) {
      return user
        .mapProjectIndexToBackgroundColor(
        user.selectedProjectIndex);
    } else {
      return user.isWorking && percent == 1 ? user.mapProjectIndexToForegroundColor(user.selectedProjectIndex) : Colors.grey.withOpacity(0.8);
    }
  }

  Color getForegroundColor() {
    return user.mapProjectIndexToForegroundColor(
        user.selectedProjectIndex);
  }

  List<Color> getConfettiColors() {
    return [
      user.mapProjectIndexToForegroundColor(user.selectedProjectIndex),
      user.mapProjectIndexToBackgroundColor(user.selectedProjectIndex),
    ];
  }

  Color getTextColor() {
    if (percent < 1) {
      return user
        .mapProjectIndexToForegroundColor(
        user.selectedProjectIndex);
    } else {
      return Colors.white;
    }
  }

  ConfettiWidget getConfettiWidget(List<Color> colors) {
    return ConfettiWidget(
        confettiController: confettiController,
        blastDirection: -pi/2, // radial value - LEFT
        particleDrag: 0.05, // apply drag to the confetti
        emissionFrequency: 0.05, // how often it should emit
        numberOfParticles: 20, // number of particles to emit
        gravity: 0.1, // gravity - or fall speed
        maxBlastForce: 10,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: colors// manually specify the colors to be used
    );
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double collapsedSize = MediaQuery.of(context).size.height * .1;
    double openedSize = MediaQuery.of(context).size.height * .4;
    Duration time = user.getTimeSinceLastIntervalForWorkingProject();
    Timer.periodic(Duration(seconds: 1), (Timer t) => setState((){

    }));
    percent = getPercentageComplete(time, user.projects[user.selectedProjectIndex].goalIntervalLengthInSeconds ?? 0);
    Color progressBackgroundColor = getBackgroundColor();
    Color progressForegroundColor = getForegroundColor();
    Color progressTextColor = getTextColor();

    return Stack(
      children: [
        Scaffold(
                extendBodyBehindAppBar: true,
                body: SlidingUpPanel(
                  controller: panelController,
                  onPanelSlide: (value) {
                    setState(() {
                      panelOpacity = value;
                    });
                  },
                  onPanelClosed: () {

                  },
                  maxHeight: openedSize,
                  minHeight: collapsedSize,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                  boxShadow: [],
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 50,
                        ),
                        Consumer<User>(
                          builder: (context, user, child) {
                            return CircularPercentIndicator(
                              radius: width / 3,
                              lineWidth: 20,
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: progressForegroundColor,
                              startAngle: 180,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              percent: percent,
                              center: Padding(
                                padding: const EdgeInsets.all(20),
                                child: ClipOval(
                                  child: Container(
                                    color: progressBackgroundColor,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(user.isWorking ? working : notWorking,
                                            style: TextStyle(color: progressTextColor,
                                                fontSize: 20),),
                                          Text(_printDuration(time),
                                            style: TextStyle(color: Theme
                                                .of(context)
                                                .scaffoldBackgroundColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 39),),
                                          if (user.isWorking && percent != 1) Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Icon(Icons.flag_outlined, color: progressTextColor,),
                                              Text(_printDuration(Duration(seconds: user.projects[user.selectedProjectIndex].goalIntervalLengthInSeconds)), style: TextStyle(
                                                color:progressTextColor,),)
                                            ],
                                          ) else if(user.isWorking && percent == 1)
                                            Text('Take a Break!', style: TextStyle(
                                              color: progressTextColor,),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Align(alignment: Alignment.topLeft,child: Text(dateString, style: TextStyle(fontSize: 25, color: Colors.grey[700]))),
                              ),
                              // Row(
                              //   children: [
                              //     // Switch(
                              //     //   onChanged: (value) {
                              //     //     setState(() {
                              //     //       user.atDesk = value;
                              //     //     });
                              //     //     // Client().updateAtDesk(user.atDesk, user.id);
                              //     //   },
                              //     //   value: user.atDesk,
                              //     // ),
                              //     // IconButton(
                              //     //   onPressed: () {
                              //     //     Client().updateStatus(user.id, user.atDesk);
                              //     //   },
                              //     //   icon: Icon(Icons.cloud_download, color: Colors.grey[700],),
                              //     // ),
                              //   ],
                              // )
                            ],
                          ),
                        ),
                        CarouselSlider.builder(
                          itemCount: 30,
                          options: CarouselOptions(
                            aspectRatio: 1,
                            viewportFraction: 1,
                            reverse: true,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                dateString = getDayString(DateTime.now().subtract(Duration(days: index)));
                              });
                            }
                          ),
                          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                            DateTime now = DateTime.now();
                            DateTime offsetDate = now.subtract(Duration(days: itemIndex));
                            // print('now: $now');
                            // print('offsetDate: $offsetDate');
                            // print('index: $itemIndex');

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Consumer<User>(
                                          builder: (context, user, child) {
                                            return IntervalGraph(
                                              dateTime: offsetDate,
                                            );
                                          }
                                      ),
                                    ),
                                    width: width,
                                  ),
                                ),
                                Container(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Consumer<User>(
                                          builder: (context, user, child) {
                                            return ProjectTotalTimeGraph(
                                              dateTime: offsetDate,
                                              height: height * .1,
                                            );
                                          }
                                      )
                                  ),
                                  width: width,
                                ),
                              ],
                            );
                          }
                        ),

                      ],
                    ),
                  ),
                  panel: Consumer<User>(
                    builder: (context, user, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                ),
                                height: 8,
                                width: 50,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 28, right: 28, bottom: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Projects.',
                                    style: TextStyle(
                                        fontSize: 38, color: Colors.grey[700]),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: user.mapProjectIndexToBackgroundColor(
                                          user.selectedProjectIndex),
                                      border: Border.all(width: 5,
                                        color: user.mapProjectIndexToForegroundColor(
                                            user.selectedProjectIndex),),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 15),
                                      child: Text(
                                        user.projects[user.selectedProjectIndex].name,
                                        style: TextStyle(color: user
                                            .mapProjectIndexToForegroundColor(
                                            user.selectedProjectIndex)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: panelOpacity,
                            duration: Duration(milliseconds: 300),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                  ),
                                ),
                                Wrap(
                                  runSpacing: 10,
                                  spacing: 10,
                                  children: projectButtons(),
                                ),
                              ],
                            ),
                          ),

                        ],
                      );
                    }
                  ),
                ),
              ),
        Positioned(
          right: MediaQuery.of(context).size.width / 2,
          top: MediaQuery.of(context).size.width / 3,
          child: confettiWidget
        ),
      ],
    );
  }

  String getDayString(DateTime dateTime) {
    DateTime today = DateTime.now();
    if(dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
      return 'Today.';
    }
    String formattedDate = DateFormat('MMMEd').format(dateTime);
    return formattedDate + '.';
  }

  List<Widget> projectButtons() {
    List<Widget> buttons = [];
    for(int i = 0; i < user.projects.length; i++) {
      buttons.add(ProjectButton(backgroundColor: user.mapProjectIndexToBackgroundColor(i), foregroundColor: user.mapProjectIndexToForegroundColor(i), project: user.projects[i], selected: user.selectedProjectIndex == i,
        onPressed: () {
          Client().updateCurrentWorkingProject(i, user.id);
      },
        onSettingPressed: () {
          TextEditingController controller = TextEditingController(text: user.projects[i].name);
          TextEditingController hourController = TextEditingController(text: durationToHours(Duration(seconds: user.projects[i].goalIntervalLengthInSeconds)));
          TextEditingController minutesController = TextEditingController(text: durationToMinutes(Duration(seconds: user.projects[i].goalIntervalLengthInSeconds)));
          print('here');
          print(controller);
          print(user.projects[i].name);
          Get.defaultDialog(
              title: '',
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Settings.',
                      style: TextStyle(
                          fontSize: 30, color: Colors.grey[700]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextFormField(
                          cursorColor: user.mapProjectIndexToForegroundColor(i),
                          controller: controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(100)
                      ),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextFormField(
                                keyboardType: TextInputType.datetime,
                                cursorColor: user.mapProjectIndexToForegroundColor(i),
                                controller: hourController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Hour',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: TextFormField(
                                keyboardType: TextInputType.datetime,
                                cursorColor: user.mapProjectIndexToForegroundColor(i),
                                controller: minutesController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Minutes',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            confirm: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FloatingActionButton.extended(
                elevation: 0,
                backgroundColor: user.mapProjectIndexToForegroundColor(i),
                label: Text('Update'),
                  onPressed: () {
                  Client().updateProjectName(controller.text, i, user.id);
                  Client().updateGoalIntervalLengthForProject(user.id, i, int.tryParse(hourController.text), int.tryParse(minutesController.text));
                  Get.back();
              }, icon: Icon(Icons.done)),
            )
          );
        },

      ));
    }
    return buttons;
  }
  

}

class ProjectButton extends StatelessWidget {
  Project project;
  Color backgroundColor;
  Color foregroundColor;
  bool selected;
  Function onPressed;
  Function onSettingPressed;
  ProjectButton({Key key, @required this.backgroundColor, @required this.foregroundColor, @required this.project, this.selected = false, this.onPressed, this.onSettingPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        width: width / 2.3,
        height: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: foregroundColor, width: 10) : null
        ),
        child: Stack(
          children: [
            Positioned(top: selected ? -10 : 0, right: selected ? -10 : 0,child: IconButton(onPressed: () {
              onSettingPressed();
            }, icon: Icon(Icons.settings, color: foregroundColor,))),
            Center(child: Text(project.name, style: TextStyle(color: foregroundColor, fontWeight: FontWeight.bold),)),
          ],
        ),
      ),
    );
  }
}

class IntervalGraph extends StatefulWidget {
  DateTime dateTime;
  IntervalGraph({Key key, this.dateTime}) {
    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  @override
  _IntervalGraphState createState() => _IntervalGraphState();
}

class _IntervalGraphState extends State<IntervalGraph> {
  User user;
  @override
  void initState() {
    user = Provider.of<User>(context, listen: false);
    super.initState();
  }
  double barHeight = 10;
  
  Widget getBar(Project project, int seconds, {bool isNotWorking = false}) {
    return Expanded(
      flex: seconds,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: !isNotWorking ? user.mapProjectIndexToBackgroundColor(user.getIndexFromProject(project)) : Colors.grey.withOpacity(0.2),
        ),
        height: barHeight,
      ),
    );
  }

  List<Widget> getBars(Project project, List<Interval.Interval> intervals) {
    List<Widget> bars = [];
    DateTime nextDay = widget.dateTime.add(Duration(days: 1));
    Interval.Interval prev;
    bool onlyNotWorking = true;
    for(int i = 0; i < intervals.length; i++) {
      Interval.Interval current = intervals[i];

      if(i == 0 && current.startTimeStamp.isAfter(widget.dateTime)) { /// Checking how many seconds to add before starting workin
        int seconds = current.startTimeStamp.difference(widget.dateTime).inSeconds;
        if(seconds > 0) {
          bars.add(getBar(project, seconds, isNotWorking: true));
        }
      }

      if(prev != null) {
        int seconds = current.getStartTime().difference(prev.getEndTime()).inSeconds;
        if(seconds > 0) {
          bars.add(getBar(project, seconds, isNotWorking: true)); /// Adding the break time in between intervals
        }
      }

      int seconds = current.intervalInSeconds();
      if(seconds > 0) {
        bars.add(getBar(project, seconds)); /// Adding current interval
        onlyNotWorking = false;
      }


      if(i == intervals.length - 1 && current.getEndTime().isBefore(nextDay)) {
        int seconds = nextDay.difference(current.getEndTime()).inSeconds;
        if(seconds > 0) {
          bars.add(getBar(project, seconds, isNotWorking: true)); /// Adding the rest of the seconds in the day
        }

      }
      prev = intervals[i];
    }
    if(onlyNotWorking) {
      bars = [getBar(project, nextDay.difference(widget.dateTime).inSeconds, isNotWorking: true)];
    }
    return bars;
  }

  int getPaddingBeforeNow() {
    int padding = DateTime.now().difference(widget.dateTime).inSeconds;
    return padding;
  }

  int getPaddingAfterNow() {
    DateTime nextDay = widget.dateTime.add(Duration(days: 1));
    int padding = nextDay.difference(DateTime.now()).inSeconds;
    return padding;
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20)
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Align(alignment: Alignment.topLeft,child: Text('Timeline.', style: TextStyle(color: Colors.grey, fontSize: 17))),
                Column(
                  children: user.projects.map((e)
                    {
                      List<Interval.Interval> intervalsToShow = e.getIntervalsForDate(widget.dateTime);
                       return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: getBars(e, intervalsToShow)
                          ),
                        );
                      },).toList()
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('0h', style: TextStyle(color: Colors.grey.withOpacity(0.5)),),
                      ],
                    ),
                    Row(
                      children: [
                        Text('12h', style: TextStyle(color: Colors.grey.withOpacity(0.5)),),
                      ],
                    ),
                    Row(
                      children: [
                        Text('24h', style: TextStyle(color: Colors.grey.withOpacity(0.5)),)
                      ],
                    ),
                  ],
                )
              ],
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                flex: getPaddingBeforeNow(),
                child: Container(
                  height: barHeight*13,
                  color: Colors.transparent,
                ),
              ),
              Expanded(
                flex: 500,
                child: Column(
                  children: [
                    Container(
                      height: barHeight*4,
                      child: Container(
                      ),
                    ),
                    Container(
                      height: barHeight*9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[400]
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: getPaddingAfterNow(),
                child: Container(
                  height: barHeight*13,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ProjectTotalTimeGraph extends StatefulWidget {
  final double height;
  final DateTime dateTime;
  ProjectTotalTimeGraph({this.height, this.dateTime});
  @override
  _ProjectTotalTimeGraphState createState() => _ProjectTotalTimeGraphState();
}

class _ProjectTotalTimeGraphState extends State<ProjectTotalTimeGraph> {
  User user;
  double barWidth = 20;
  @override
  void initState() {
    user = Provider.of<User>(context, listen: false);
    print(widget.dateTime);
    super.initState();
  }

  double getBarHeight(int totalTimeSpent) {
    if(totalTimeSpent == 0) {
      return 0;
    }
    if(user.getMostTimeSpentOnDate(widget.dateTime) == 0) {
      return 0;
    }
    double height = widget.height * (totalTimeSpent/user.getMostTimeSpentOnDate(widget.dateTime));
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20)
      ),

      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Align(alignment: Alignment.topLeft,child: Text('Total time.', style: TextStyle(color: Colors.grey, fontSize: 17))),
              ),
              Flex(
                direction: Axis.horizontal,
                children: user.projects.map((e) =>
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                          ),
                          width: barWidth,
                          height: getBarHeight(user.getMostTimeSpentOnDate(widget.dateTime)) - getBarHeight(e.getTotalTimeSpentInSecondsOnDate(widget.dateTime)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: user.mapProjectIndexToBackgroundColor(user.getIndexFromProject(e)),
                          ),
                          width: barWidth,
                          height: getBarHeight(e.getTotalTimeSpentInSecondsOnDate(widget.dateTime)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(e.name, style: TextStyle(color: user.mapProjectIndexToForegroundColor(user.getIndexFromProject(e))),),
                        )
                      ],
                    ),
                  )
                ).toList(),
              ),
            ],
          ),
      ),
    );
  }
}

