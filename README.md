# Raspberry Pi 5 ArmPi Mini Robotic Arm Setup

A comprehensive initialization script for setting up a fresh Raspberry Pi 5 installation to work with the **Hiwonder ArmPi Mini 5DOF Vision Robotic Arm** and **ROS2 Humble** ecosystem.

## 🤖 What This Script Does

This script prepares your Raspberry Pi 5 for advanced robotics development by installing and configuring:

### Core Systems
- **ROS2 Humble Hawksbill** - Complete robotics middleware
- **Ubuntu 22.04 LTS** compatibility verification
- **MoveIt** motion planning framework
- **tf2** coordinate frame management

### Computer Vision & AI
- **OpenCV** with Python bindings
- **MediaPipe** for hand/pose detection
- **TensorFlow** for machine learning
- **PyTorch** for deep learning
- **YOLO (Ultralytics)** for object detection
- **Face recognition** libraries

### Hardware Control
- **pigpio** for precise servo control
- **gpiozero** for GPIO management
- **Serial communication** libraries
- **Camera support** (libcamera + V4L2)
- **USB device management**

### Development Environment
- **Inverse kinematics** libraries
- **Spatial mathematics** tools
- **ROS2 workspace** setup
- **Test scripts** for validation
- **Remote access** via VNC
- **System optimization** for robotics

## 📋 Prerequisites

### Hardware Requirements
- **Raspberry Pi 5** (4GB or 8GB RAM recommended)
- **MicroSD card** (32GB minimum, Class 10 recommended)
- **ArmPi Mini** robotic arm by Hiwonder
- **USB camera** (typically included with ArmPi Mini)
- **Power supply** (5V/3A for Pi 5)

### Software Requirements
- **Ubuntu 22.04 LTS (64-bit)** for Raspberry Pi
- **Internet connection** for downloading packages
- **SSH access** or direct terminal access

## 🚀 Quick Start

### 1. Download and Run the Script

```bash
# Download the script
wget https://raw.githubusercontent.com/your-repo/rpi5_armpi_mini_setup.sh

# Make it executable
chmod +x rpi5_armpi_mini_setup.sh

# Run the installation
./rpi5_armpi_mini_setup.sh
```

### 2. Follow the Interactive Prompts

The script will:
- Verify your system compatibility
- Ask for confirmation before major installations
- Display progress with colored output
- Handle errors gracefully

### 3. Reboot After Installation

```bash
sudo reboot
```

## 🧪 Testing Your Installation

After reboot, test the various components:

### Camera Test
```bash
python3 ~/armpi_workspace/test_camera.py
```

### Servo Communication Test
```bash
python3 ~/armpi_workspace/test_servo.py
```

### ROS2 Integration Test
```bash
source ~/.bashrc
python3 ~/armpi_workspace/test_ros2_integration.py
```

### Quick Camera Check
```bash
camera-test  # Alias created by the script
```

## 📁 Directory Structure

The script creates the following workspace structure:

```
~/armpi_workspace/
├── src/                    # Source code directory
├── test_camera.py         # Camera functionality test
├── test_servo.py          # Servo communication test
├── test_ros2_integration.py # ROS2 integration test
└── armpi_main.py          # Main service script template

~/ros2_ws/
├── src/                   # ROS2 packages
├── build/                 # Build artifacts
├── install/               # Installation files
└── log/                   # Build logs
```

## 🔧 Configuration Details

### ROS2 Packages Installed
- `ros-humble-ros-base` - Core ROS2 without GUI
- `ros-humble-moveit` - Motion planning framework
- `ros-humble-tf2-*` - Coordinate transformations
- `ros-humble-joint-state-publisher` - Joint state management
- `ros-humble-robot-state-publisher` - Robot state publishing
- `python3-colcon-common-extensions` - Build tools

### Python Libraries Installed
- **Scientific Computing**: NumPy, SciPy, Matplotlib, Pandas
- **Computer Vision**: OpenCV, Scikit-image, Pillow
- **Machine Learning**: TensorFlow, PyTorch, Scikit-learn
- **Robotics**: Modern-robotics, Robotics-toolbox-python, IKPy
- **Hardware Control**: pySerial, gpiozero, RPi.GPIO, pigpio
- **Communication**: Flask, WebSockets, MQTT, Requests

### System Optimizations
- **GPU Memory**: Increased to 128MB for camera operations
- **Real-time Priority**: Configured for robotics applications
- **Swap Space**: 2GB added for AI operations
- **USB Permissions**: Configured for robotic devices
- **Camera Interface**: Enabled and optimized

## 🛠 ArmPi Mini Specific Features

### Servo Control
- **pigpio daemon** for precise timing
- **Serial communication** setup for arm control
- **GPIO permissions** for hardware access
- **USB device rules** for consistent device naming

### Computer Vision
- **Wide-angle camera** support (170° FOV)
- **OpenCV integration** for image processing
- **AI vision libraries** for object recognition
- **Real-time processing** optimization

### Inverse Kinematics
- **IKPy library** for kinematic calculations
- **Robotics Toolbox** for advanced robotics math
- **Spatial mathematics** tools
- **MoveIt integration** for motion planning

## 📡 Remote Access

The script configures multiple remote access methods:

### VNC Server
```bash
# VNC is auto-configured and starts on boot
# Connect to: <raspberry_pi_ip>:5901
```

### SSH
```bash
# SSH is typically enabled by default
ssh ubuntu@<raspberry_pi_ip>
```

### Web Interface (if using Flask apps)
```bash
# Access via browser at: http://<raspberry_pi_ip>:5000
```

## 🔄 Auto-Start Service

The script creates a systemd service for automatic ArmPi Mini startup:

```bash
# Enable auto-start
sudo systemctl enable armpi-mini

# Start service manually
sudo systemctl start armpi-mini

# Check service status
sudo systemctl status armpi-mini

# View service logs
journalctl -u armpi-mini -f
```

## 🎯 ROS2 Development

### Basic ROS2 Commands
```bash
# List available topics
ros2 topic list

# List running nodes
ros2 node list

# Echo a topic
ros2 topic echo /joint_states

# Launch a node
ros2 run <package> <node>
```

### Building ROS2 Packages
```bash
# Navigate to workspace
cd ~/ros2_ws

# Build all packages
colcon build

# Source the workspace
source install/setup.bash

# Build specific package
colcon build --packages-select <package_name>
```

### Useful Aliases Created
- `ros2-build` - Quick workspace build
- `ros2-source` - Source workspace
- `armpi-start` - Navigate to armpi workspace
- `start-pigpio` - Start pigpio daemon
- `camera-test` - Test camera quickly

## 🐛 Troubleshooting

### Common Issues

#### Camera Not Detected
```bash
# Check camera connection
lsusb

# Test with v4l2
v4l2-ctl --list-devices

# Check camera interface
vcgencmd get_camera
```

#### Servo Communication Problems
```bash
# Check serial devices
ls -la /dev/tty*

# Test pigpio daemon
sudo systemctl status pigpiod

# Check user permissions
groups $USER
```

#### ROS2 Package Not Found
```bash
# Check ROS2 installation
ros2 --version

# Source ROS2 environment
source /opt/ros/humble/setup.bash

# Rebuild workspace
cd ~/ros2_ws && colcon build
```

#### Permission Denied Errors
```bash
# Check user groups
groups $USER

# Add to necessary groups
sudo usermod -a -G dialout,gpio,video $USER

# Reboot to apply changes
sudo reboot
```

### System Performance

#### Memory Usage
```bash
# Check memory usage
free -h

# Monitor with htop
htop
```

#### CPU Temperature
```bash
# Check CPU temperature
vcgencmd measure_temp

# Monitor continuously
watch -n 1 vcgencmd measure_temp
```

## 📚 Additional Resources

### ArmPi Mini Documentation
- [Hiwonder Official Documentation](https://docs.hiwonder.com/)
- [ArmPi Mini Product Page](https://www.hiwonder.com/collections/raspberry-pi/products/armpi-mini)

### ROS2 Learning Resources
- [ROS2 Official Documentation](https://docs.ros.org/en/humble/)
- [ROS2 Tutorials](https://docs.ros.org/en/humble/Tutorials.html)
- [MoveIt Documentation](https://moveit.ros.org/)

### Computer Vision with OpenCV
- [OpenCV Python Tutorials](https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html)
- [MediaPipe Solutions](https://google.github.io/mediapipe/)

## 🤝 Contributing

Feel free to contribute improvements to this setup script:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on Raspberry Pi 5
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This script is provided "as is" without warranty. Always backup your system before running automated installation scripts. Test thoroughly in your specific environment before using in production.

## 📞 Support

For issues related to:
- **ArmPi Mini Hardware**: Contact Hiwonder support
- **ROS2**: Check ROS2 community forums
- **This Script**: Open an issue in this repository

---

**Happy Robotics Development! 🤖✨**
