# 🚗 FPGA-Based Autonomous RC Car

An autonomous RC car project built using an FPGA board(Xilinx CMOD-S7) and multiple sensors. The car supports both automatic and manual driving modes and can be fully controlled via a Bluetooth-connected Android smartphone.

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

- FPGA Board (Xilinx CMOS S7)
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

## 📸 Demo

![image](https://github.com/user-attachments/assets/3c96adec-5f59-4ca2-ba17-af8ae95bb72e)
![image](https://github.com/user-attachments/assets/4e5c6183-2e3c-492f-9a5f-cdb0362140ab)

