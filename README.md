**IoT-Based Fire Detection and Monitoring System using TinyML**

An intelligent, real-time fire detection and monitoring system designed to provide early warnings and minimize false alarms by leveraging edge AI (TinyML), multi-sensor data fusion, an ESP32 microcontroller, and a custom Flutter mobile application.

🚀 Project Overview

Traditional fire detection systems are often prone to false alarms caused by everyday smoke or dust. This project addresses this limitation by deploying an embedded machine learning (TinyML) model directly on an ESP32 microcontroller. The system continuously monitors environmental parameters using a multi-sensor array (MQ-2 gas/smoke sensor, DHT11 temperature/humidity sensor, and a flame sensor), processes the data locally for accurate classification, and communicates real-time alerts to users via a cloud-connected Flutter mobile application.

✨ Key Features

Multi-Sensor Fusion: Combines data from MQ-2, DHT11, and flame sensors for robust and accurate hazard detection.

On-Device Machine Learning (TinyML): Runs classification algorithms directly on the ESP32 edge device to significantly reduce false alarms.

Real-Time Cloud Synchronization: Integrates with Google Firebase Realtime Database for seamless data logging and instant updates.

Cross-Platform Mobile App: Built with Flutter to deliver instant push notifications, live status telemetry (SAFE, GAS_ALERT, FIRE_ALERT), and a clean user dashboard.

Local Alerting: Equipped with a local buzzer activation mechanism upon immediate hazard confirmation.

🛠️ Technology Stack & Hardware Components

Hardware Components

Microcontroller: ESP32 DevKit V1 (Wi-Fi enabled)

Sensors:

MQ-2 Smoke and Gas Sensor

DHT11 Temperature and Humidity Sensor

Infrared/UV Flame Sensor

Output Devices: Active Buzzer, Jumper Wires, Breadboard

Software & Tools

Embedded Development: Arduino IDE (C++)

Machine Learning: Edge Impulse / TinyML Framework

Cloud Backend: Google Firebase Realtime Database

Mobile Application: Flutter (Dart)

📐 System Architecture

[ Sensor Array (MQ-2, DHT11, Flame) ]
              │
              ▼
    [ ESP32 Microcontroller ] (TinyML Inference Engine)
              │
              ▼ (Wi-Fi / MQTT / HTTPS)
      [ Firebase Cloud Server ]
              │
              ▼
   [ Flutter Mobile Application ] (Live Alerts & Dashboard)


📂 Repository Structure

📦 IoT-Fire-Detection-System-TinyML
├── 📁 arduino/                 # ESP32 C++ sketches and TinyML model code
│   └── fire_detection_esp32.ino
├── 📁 mobile_app/              # Flutter application source code (lib folder)
│   ├── 📁 lib/
│   │   ├── main.dart
│   │   └── ...
│   └── pubspec.yaml
├── 📁 hardware_diagrams/       # Circuit schematics and hardware implementation photos
└── README.md                   # Project documentation


⚙️ Setup and Installation

1. Hardware Setup

Connect the MQ-2 sensor, DHT11 sensor, and flame sensor to the respective analog/digital pins of the ESP32 as outlined in the circuit diagram.

Ensure proper power supply connections using a breadboard and jumper wires.

2. Firmware (Arduino IDE)

Open the .ino file located in the arduino/ folder using the Arduino IDE.

Install the required libraries (ESP32 board package, DHT sensor library, Firebase ESP client).

Update your Wi-Fi credentials and Firebase database URL in the code.

Select your ESP32 board and port, then upload the code.

3. Mobile App (Flutter)

Navigate to the mobile_app/ directory.

Run flutter pub get to fetch dependencies.

Configure your Firebase connection (google-services.json / initialization settings).

Run the app using flutter run on an Android or iOS device.

🔮 Future Scope

Integration with smart home automation (e.g., automatic water sprinkler system activation).

Advanced predictive analytics using historical sensor data logs.

GPS location tracking and direct emergency service dispatch integration.

📄 License

This project is developed as a Final Year Project (FYP) for academic purposes at MY University, Islamabad.
