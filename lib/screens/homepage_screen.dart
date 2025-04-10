import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hydration/components/water_entry.dart';
import 'package:hydration/models/water_intake_data.dart';
import 'package:hydration/models/water_tracker_data.dart';
import 'package:hydration/utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  List<WaterIntakeData> waterEntries = [];

  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initNotifications();

    _fetchAndSchedule();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchData() async {
    final data = await WaterTrackerData().getEntriesForDate(Utils.db, selectedDate);
    setState(() {
      waterEntries = data;
    });
  }

  Future<void> _fetchAndSchedule() async {
    await _fetchData();
    await _cancelNotification();
    if (waterEntries.isNotEmpty) {
      await _scheduleNotification();
    }
  }

  Future<void> _addWaterEntry() async {
    final now = DateTime.now();
    final entry = WaterIntakeData(date: selectedDate, createDateTime: now);
    await WaterTrackerData().insertEntry(Utils.db, entry);
    await _fetchAndSchedule();
  }

  Future<void> _deleteWaterEntry(int id) async {
    await WaterTrackerData().deleteEntry(Utils.db, id);
    await _fetchAndSchedule();
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _scheduleNotification() async {
    DateTime lastWaterIntake = waterEntries.last.createDateTime;
    DateTime scheduledTime = lastWaterIntake.add(const Duration(hours: 3));
    final now = DateTime.now();

    if (scheduledTime.isAfter(now)) {
      if (scheduledTime.hour >= 23 || scheduledTime.hour < 7) {
        if (scheduledTime.hour >= 23) {
          scheduledTime = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day).add(const Duration(days: 1, hours: 7));
        } else if (scheduledTime.hour < 7) {
          scheduledTime = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day, 7);
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'water_notification_channel',
        'Water Notifications',
        channelDescription: 'Notification to remind you to drink water',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Hydration Reminder',
        'It’s time to drink water!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        matchDateTimeComponents: null,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final giorniSettimana = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idratazione Giornaliera'),
        backgroundColor: Colors.blue.shade200,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "${giorniSettimana[selectedDate.weekday - 1]} ${Utils.getFormattedDate(selectedDate)}",
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: waterEntries.length,
              itemBuilder: (context, index) {
                final entry = waterEntries[index];
                return WaterEntry(
                  waterData: entry,
                  onDelete: () => _deleteWaterEntry(entry.id),
                );
              },
            ),
          ),
          const SizedBox(height: 84)
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 32,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                'Acqua bevuta: ${waterEntries.length * 0.25} L',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: _addWaterEntry,
              tooltip: 'Aggiungi bicchiere d’acqua',
              backgroundColor: Colors.lightBlue,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue.shade900,
        backgroundColor: Colors.blue.shade50,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back_ios), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_forward_ios), label: ''),
        ],
        onTap: (value) async {
          if (value == 0) {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          } else if (value == 1) {
            setState(() {
              selectedDate = DateTime.now();
            });
          } else if (value == 2) {
            setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            });
          }
          await _fetchAndSchedule();
        },
      ),
    );
  }
}
