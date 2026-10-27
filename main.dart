import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Local Notifications Initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
  );
}

// --- 1. CENTERED & HIGHLY VISIBLE FIRE SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FireDetectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF3B0000),
              Color(0xFFB71C1C),
              Colors.black,
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      size: 100,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "SMART FIRE DETECTION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "AI & Sensor Based Safety System",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 15,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. ADVANCED PROFESSIONAL DASHBOARD ---
class FireDetectionScreen extends StatefulWidget {
  const FireDetectionScreen({super.key});
  @override
  State<FireDetectionScreen> createState() => _FireDetectionScreenState();
}

class _FireDetectionScreenState extends State<FireDetectionScreen> {
  final ref = FirebaseDatabase.instance.ref("fireSystem");

  String lastRecordedAlert = "None";
  String lastAlertTime = "--:--:--";
  String previousStatus = "";

  // Function to show local notification
  Future<void> _showFireNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'fire_alert_channel',
          'Fire & Gas Alerts',
          channelDescription:
              'Critical alerts for fire and gas leakage detection',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          color: Colors.red,
          ledColor: Colors.red,
          ledOnMs: 1000,
          ledOffMs: 500,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "SAFE":
        return Colors.green.shade700;
      case "GAS_LEAK":
      case "GAS LEAK WARNING":
        return Colors.amber.shade800;
      case "SMOKE_WARNING":
      case "SMOKE WARNING":
        return Colors.orange.shade800;
      case "FIRE_ALERT":
      case "FIRE ALERT":
        return Colors.red.shade700;
      case "CRITICAL_FIRE":
      case "CRITICAL FIRE":
        return Colors.red.shade900;
      default:
        return Colors.blueGrey;
    }
  }

  Color getBackgroundTint(String status) {
    switch (status) {
      case "GAS_LEAK":
      case "GAS LEAK WARNING":
      case "SMOKE_WARNING":
      case "SMOKE WARNING":
        return const Color(0xFFFFF9C4);
      case "FIRE_ALERT":
      case "FIRE ALERT":
        return const Color(0xFFFFCDD2);
      case "CRITICAL_FIRE":
      case "CRITICAL FIRE":
        return const Color(0xFFEF9A9A);
      default:
        return const Color(0xFFEFEFEF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.onValue,
      builder: (context, snapshot) {
        bool isConnected =
            snapshot.hasData && snapshot.data!.snapshot.value != null;

        Map data = {};
        if (isConnected) {
          data = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          String currentStatus = data['status'] ?? "SAFE";

          if (currentStatus != "SAFE" && currentStatus != previousStatus) {
            previousStatus = currentStatus;

            // Trigger Notification when alert occurs
            _showFireNotification(
              "⚠️ EMERGENCY ALERT: $currentStatus",
              "Sensor detected critical condition. Check dashboard immediately!",
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  lastRecordedAlert = currentStatus;
                  DateTime now = DateTime.now();
                  lastAlertTime =
                      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                });
              }
            });
          } else if (currentStatus == "SAFE" && previousStatus != "SAFE") {
            previousStatus = currentStatus;
          }
        }

        String currentStatus = data['status'] ?? "UNKNOWN";
        Color themeColor = getStatusColor(currentStatus);
        Color screenBgColor = getBackgroundTint(currentStatus);

        return Scaffold(
          backgroundColor: screenBgColor,
          appBar: AppBar(
            elevation: 4,
            backgroundColor: Colors.black,
            centerTitle: true,
            title: const Text(
              "FIRE MONITORING DASHBOARD",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isConnected ? Colors.greenAccent : Colors.redAccent)
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isConnected
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: isConnected
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          size: 10,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected ? "LIVE" : "OFFLINE",
                          style: TextStyle(
                            color: isConnected
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            _buildFirebaseStatusCard(isConnected),
                            const SizedBox(height: 14),

                            if (!isConnected)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 80.0),
                                child: Center(
                                  child: Text(
                                    "Waiting for sensor data from Firebase...",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            else
                              _buildAdvancedDashboardContent(data, themeColor),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text(
                            "AI Fire & Gas Safety System • Powered by ESP32",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFirebaseStatusCard(bool isConnected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConnected
              ? Colors.green.withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: isConnected ? Colors.green.shade800 : Colors.red.shade800,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DATABASE STATUS",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected
                      ? "Connected to path: /fireSystem"
                      : "Disconnected / No Data Found",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isConnected
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedDashboardContent(Map data, Color themeColor) {
    String status = data['status'] ?? "UNKNOWN";
    String temp = data['temperature']?.toString() ?? "0";
    String mq2Value = data['mq2']?.toString() ?? "0";

    // Updated to check 'flame_detected' matching your Firebase tree structure
    bool isFlameDetected =
        data['flame_detected'] == 1 ||
        data['flame_detected'] == true ||
        data['flame_detected'] == "1" ||
        data['flame_detected'] == "YES" ||
        data['flame_detected'] == "true";

    String confidence = data['confidence'] != null
        ? "${(data['confidence'] as num).toStringAsFixed(1)}%"
        : "0%";

    return Column(
      children: [
        // Main Status Card
        Card(
          elevation: 10,
          shadowColor: themeColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor.withOpacity(0.85), themeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.security, size: 60, color: Colors.white),
                const SizedBox(height: 14),
                const Text(
                  "SYSTEM STATUS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Flame Sensor Status Card
        _buildFlameStatusCard(isFlameDetected),
        const SizedBox(height: 14),

        // Last Alert Section Card
        Card(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.deepOrange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "LAST RECORDED ALERT",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$lastRecordedAlert  ($lastAlertTime)",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Sensors Metric Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Temperature",
                "$temp°C",
                Icons.thermostat,
                Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                "Smoke / Gas",
                mq2Value,
                Icons.cloud,
                Colors.orange.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildMetricCard(
          "AI Model Confidence",
          confidence,
          Icons.psychology,
          Colors.purple.shade700,
        ),
      ],
    );
  }

  Widget _buildFlameStatusCard(bool flameDetected) {
    return Card(
      elevation: 6,
      shadowColor: flameDetected
          ? Colors.red.withOpacity(0.5)
          : Colors.green.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: flameDetected ? Colors.red.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: flameDetected ? Colors.red.shade400 : Colors.green.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (flameDetected ? Colors.red : Colors.green).withOpacity(
                  0.2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                flameDetected
                    ? Icons.local_fire_department
                    : Icons.check_circle,
                color: flameDetected
                    ? Colors.red.shade800
                    : Colors.green.shade800,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FLAME SENSOR STATUS",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    flameDetected
                        ? "FLAME DETECTED! 🚨"
                        : "No Flame Detected (Safe)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: flameDetected
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
