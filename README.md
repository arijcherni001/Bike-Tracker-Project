🚴‍♂️ Bike Tracker – Smart IoT & Embedded Solution

Collaborative project integrating embedded systems, IoT, and mobile development to create a real-time smart bike tracking system.

🔹 Project Overview

The Bike Tracker project leverages cutting-edge IoT and mobile technologies to provide a seamless, real-time tracking experience. The system combines an embedded microcontroller, GPS, and Bluetooth connectivity with a user-friendly mobile application.

Key Features:

Real-Time Location Tracking: View your bike’s location live on an interactive map.

Speed Monitoring & Ride History: Track performance and review past rides.

User & Bike Management: Add, edit, and manage user profiles and bike information through an intuitive interface.

Wireless Data Communication: Seamless Bluetooth data transfer from embedded hardware to the mobile app.

This project enhanced skills in embedded programming, GPS & Bluetooth communication, mobile cross-platform development, and collaborative teamwork.

🔧 Technologies Used

STM32F407G Microcontroller
NEO-6M GPS	Provides real-time location coordinates
HC-05 Bluetooth	Enables wireless communication between the bike and mobile app
Flutter	Cross-platform mobile application development
Firebase	Authentication, data storage, and cloud synchronization


📱 Mobile Application

The Flutter-based mobile app offers:

Map integration for real-time bike tracking

Ride statistics including speed, distance, and history

User-friendly UI for managing multiple bikes and profiles

Secure authentication using Firebase


⚙️ Hardware Architecture
[STM32F407G] --> [GPS Module (NEO-6M)]
       |
       --> [Bluetooth Module (HC-05)] --> Mobile App (Flutter)
STM32F407G reads GPS data.

Transmits location & speed to the mobile app via HC-05 Bluetooth.

Mobile app displays data in real-time and stores it in Firebase.
