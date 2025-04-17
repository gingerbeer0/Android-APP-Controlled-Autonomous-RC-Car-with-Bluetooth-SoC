# Android-APP-Controlled-Autonomous-RC-Car-with-Bluetooth-SoC

This project implements a **fully software-driven autonomous RC car system** controllable via a **custom Android application**, leveraging Bluetooth communication and FPGA-based logic control. Unlike traditional hardware-centric RC systems, this project highlights a strong **software-defined control architecture** where real-time decisions and motion commands originate from the Android layer.

## 🚀 Key Highlights

- 📱 **Android-App Integration**  
  A custom-built Android application provides an intuitive UI/UX to control the car's movement, speed, and behavior modes. The app communicates via **Bluetooth (HC-05 module)** and sends directional commands in real-time.

- 🧠 **Software-Centric Architecture**  
  The vehicle logic is designed with a **software-first approach**, where the **state machine**, **manual override**, and **autonomous behaviors** are triggered and managed through a well-defined **protocol interface** between app and car.

- 🔄 **Real-Time Mode Switching**  
  Modes such as "manual", "auto-tracking", and "obstacle-avoidance" can be switched directly from the app, reflecting instantly on the FPGA-based controller.

- 💡 **Bluetooth SoC Communication Layer**  
  The project includes a reliable, debounced, and low-latency communication stack between Android and the car using a serial Bluetooth protocol, enabling continuous software interaction without hardware interruptions.

- 🧩 **Modular Design for Scalability**  
  The system is designed with **modular Verilog blocks and software modules**, making it scalable for future AI integration, sensor fusion, or mapping logic.

This project is a great demonstration of how **mobile app development, embedded systems, and digital logic design** can be fused together into a single, cohesive real-time control system.

## 📸 Demo

![image](https://github.com/user-attachments/assets/3c96adec-5f59-4ca2-ba17-af8ae95bb72e)
![image](https://github.com/user-attachments/assets/f2e2871d-3de2-4a5c-a44d-ef006d63e8c1)


## 📱 Key Features

- **Autonomous Driving**  
  Uses a tracker & avoid sensor to follow lines and avoid obstacles without user intervention.

- **Bluetooth Control via Android App**  
  Connects to an Android smartphone via Bluetooth, allowing full control of all features through the app interface.

- **Driving Modes**  
  - **Autonomous Mode**: Sensor-based self-driving  
  - **Manual Mode (Button Control)**: Drive manually using on-screen buttons in the Android app  
  - **Manual Mode (Gyro Control)**: Drive using the phone's gyroscope sensor by tilting the device

- **Dynamic Music Playback**  
  Built-in buzzer plays theme songs:  
  🎸 Sweet Child O' Mine  
  🏴‍☠️ Pirates of the Caribbean  
  🍄 Super Mario Bros

- **Emergency Stop**  
  Automatically stops when a critical situation (e.g. accident) is detected using sound or other sensor inputs.

## 🧠 Block Diagram

![image](https://github.com/user-attachments/assets/33144e17-c4c9-4e90-8051-900cc31f9df8)


## 🛠️ Hardware Components

- FPGA Board (Xilinx CMOD S7)
- Tracker & Avoid Sensor
- Bluetooth Module (HC-05)
- Buzzer
- Flame Sensor
- Sound Sensor
- LEDs
- Android Smartphone (with custom remote app)

## 📂 Project Structure

- `top_rc_car`: Main controller module
- `drive_inst`: Handles driving logic
- `pwm_inst`: Controls wheel motors
- `uart_inst`: Communicates with Android app via Bluetooth
- `music_inst`: Generates music signals
- `fire_inst`: Handles fire/emergency detection


