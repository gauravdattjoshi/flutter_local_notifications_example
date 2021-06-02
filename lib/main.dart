import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_example/timezones.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime dateAndTime = DateTime.now();
  bool isDateChanged = false;
  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Flutter Scheduled Notification Example"),
        ),
        body: SafeArea(
            child: Center(
          child: Column(
            children: [
              pickTimeButton(context),
              RaisedButton(
                onPressed: () => {
                  scheduledNotification(
                    id: Random()
                        .nextInt(200), //generate a random integer upto 200
                    title: "Scheduled Notification Tutorial",
                    time: isDateChanged == false
                        ? DateTime.parse(
                            "${DateTime(now.year, now.month, now.day, 23, 59, 59)}")
                        : DateTime.parse("$dateAndTime"),
                  )
                },
                child: Text("Schedule"),
              )
            ],
          ),
        )));
  }

  // SCHEDULES Notification

  void scheduledNotification({int id, String title, DateTime time}) async {
    final timeZone = TimeZone();
    // The device's timezone.
    String timeZoneName = await timeZone.getTimeZoneName();
    // Find the 'current location'
    final location = await timeZone.getLocation(timeZoneName);

    final scheduledDate = tz.TZDateTime.from(time, location);

    var notificationDetails = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        icon: '@mipmap/ic_launcher', //your appicon
        importance: Importance.high,
        enableVibration: true,
        priority: Priority.high);
    var iosDetails = IOSNotificationDetails();
    await flutterLocalNotificationsPlugin
        .zonedSchedule(
            id,
            title,
            "Have you completed your goal?" ??
                "${DateFormat('d/M/y').format(time)}",
            scheduledDate,
            NotificationDetails(android: notificationDetails, iOS: iosDetails),
            payload: "Welcome",
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true)
        .then((value) => _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Notification Scheduled"))));
  }

// OTHER FUNCTIONS AND WIDGETS MAINLY FOR UI

//Responsible for showing Today Tomorrow on the button

  String checkDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final dateToCheck = date;
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return "Today";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else if (aDate == tomorrow) {
      return "Tommorow";
    } else {
      return "${DateFormat('d/M/y').format(dateToCheck)}";
    }
  }

// Opens the bottom sheet
  Future<void> bottomSheet(BuildContext context, Widget child,
      {double height}) {
    return showModalBottomSheet(
        isScrollControlled: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13), topRight: Radius.circular(13))),
        backgroundColor: Colors.white,
        context: context,
        builder: (context) => Container(
            height: height ?? MediaQuery.of(context).size.height / 3,
            child: child));
  }

// Loads Cupertino TimePicker
  OutlineButton pickTimeButton(BuildContext context) {
    return OutlineButton.icon(
      onPressed: () => bottomSheet(
        context,
        CupertinoDatePicker(
          onDateTimeChanged: (DateTime time) {
            isDateChanged = false;
            setState(
              () {
                dateAndTime = time;
                isDateChanged = true;
              },
            );
          },
          minimumYear: 2021,
          maximumYear: 2100,
          maximumDate: DateTime(2100),
          initialDateTime: DateTime.now(),
        ),
      ),
      icon: Icon(
        Icons.calendar_today,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      borderSide: BorderSide(width: 2, color: Colors.green),
      label: Text(
        "${checkDate(dateAndTime)}",
        style: TextStyle(color: Colors.black, fontSize: 23),
      ),
    );
  }
}
