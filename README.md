# A `Nerves` Driver Behavior Monitoring System

## Overview

This project is a skeleton framework aimed at monitoring driver's behavior using audio and visual sensors connected to a Raspberry Pi. The data is intended to be processed using the Elixir Nerves framework and fed to TinyML models for inference. The project also plans to integrate a YOLOv5 NIF for object detection. It is structured as an Elixir Umbrella project, consisting of two main applications: `my_app_firmware` for the Nerves firmware and `my_app_ui` for the Phoenix framework.

## Prerequisites

- Elixir (`asdf` or `exenv` recommended)
- Nerves framework
- Raspberry Pi ( anyone that's compliant with `Nerves Framework`

## Setup

### Clone the Repository

1. Clone the repository:
    ```sh
    git clone https://github.com/TheMakarov/obz_rabb.git
    cd obz_rabb
    ```

### Install Dependencies

1. Install Elixir dependencies:
    ```sh
    mix deps.get
    ```

### Build and Deploy to Raspberry Pi

1. Navigate to the `my_app_firmware` directory:
    ```sh
    obz_rabb/my_app_firmware
    ```


2. Run the script to download the YOLOv3 weights:
    ```sh
    chmod +x ./blobs/get_yolo.sh
    ./blobs/get_yolo.sh
    ```
    
3. Build the Nerves firmware:
    ```sh
    mix firmware
    ```

4. Deploy the firmware to the Raspberry Pi:
    ```sh
    mix firmware.burn
    ```

> the rust Nif will be compiled automatically .  

### Start the Phoenix Application

1. Navigate to the `my_app_ui` directory:
    ```sh
    cd obz_rabb/my_app_ui
    ```

2. Install dependencies:
    ```sh
    mix deps.get
    ```

3. Visit the application in your browser at `http://nerves.local`.


## Features

### `my_app_firmware`

- **Sensor Data Collection**: Collects data from audio and visual sensors. (not implemented yet)
- **TinyML Inference**: Planned to host at least 3 TinyML models for inference. (not implemented yet)
- **YOLOv5 Integration**: Uses a YOLOv5 NIF for object detection. (not implemented yet, all what it does know is to detect and draw boxes around usual items , e.g cars , people , cat ...)
- **Platform Introspection**: Probes device memory usage, CPU usage, and connected devices.

### `my_app_ui`

- **User Interface**: Provides a web interface for monitoring driver behavior.
- **Real-time Updates**: Displays real-time data and inference results using Phoenix LiveView.
