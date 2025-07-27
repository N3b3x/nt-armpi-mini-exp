#!/bin/bash

# =============================================================================
# Raspberry Pi 5 ArmPi Mini Robotic Arm Initialization Script
# 
# This script prepares a fresh Raspberry Pi 5 installation for use with:
# - Hiwonder ArmPi Mini 5DOF Vision Robotic Arm
# - ROS2 Humble Hawksbill
# - OpenCV and Computer Vision libraries
# - AI/ML libraries for robotics applications
#
# Usage: chmod +x rpi5_armpi_mini_setup.sh && ./rpi5_armpi_mini_setup.sh
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if running on Raspberry Pi 5
check_rpi5() {
    log "Checking if running on Raspberry Pi 5..."
    
    if grep -q "Raspberry Pi 5" /proc/cpuinfo; then
        log "✓ Raspberry Pi 5 detected"
    else
        warn "This script is optimized for Raspberry Pi 5. Continue anyway? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            error "Exiting..."
            exit 1
        fi
    fi
}

# Check Ubuntu version
check_ubuntu() {
    log "Checking Ubuntu version for ROS2 Humble compatibility..."
    
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$VERSION_ID" == "22.04" ]]; then
            log "✓ Ubuntu 22.04 detected - compatible with ROS2 Humble"
        else
            warn "Ubuntu $VERSION_ID detected. ROS2 Humble requires Ubuntu 22.04"
            warn "Continue anyway? (y/N)"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                error "Please install Ubuntu 22.04 (64-bit) for best compatibility"
                exit 1
            fi
        fi
    else
        error "Cannot determine OS version"
        exit 1
    fi
}

# Update system
update_system() {
    log "Updating system packages..."
    
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    
    log "✓ System updated successfully"
}

# Install essential development tools
install_development_tools() {
    log "Installing essential development tools..."
    
    sudo apt install -y \
        build-essential \
        cmake \
        git \
        wget \
        curl \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        pkg-config \
        libjpeg-dev \
        libtiff5-dev \
        libpng-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libv4l-dev \
        libxvidcore-dev \
        libx264-dev \
        libatlas-base-dev \
        gfortran \
        libhdf5-dev \
        libhdf5-serial-dev \
        libhdf5-103 \
        python3-pyqt5 \
        python3-dev \
        python3-pip \
        python3-venv
    
    log "✓ Development tools installed"
}

# Set up locale for ROS2
setup_locale() {
    log "Setting up locale for ROS2..."
    
    sudo apt install -y locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
    
    log "✓ Locale configured"
}

# Install ROS2 Humble
install_ros2() {
    log "Installing ROS2 Humble Hawksbill..."
    
    # Add ROS2 repository
    sudo add-apt-repository universe -y
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    
    # Update package cache
    sudo apt update
    
    # Install ROS2 base (no GUI tools for Pi optimization)
    sudo apt install -y ros-humble-ros-base
    
    # Install development tools
    sudo apt install -y ros-dev-tools
    
    # Install additional ROS2 packages commonly needed for robotic arms
    sudo apt install -y \
        ros-humble-example-interfaces \
        ros-humble-geometry-msgs \
        ros-humble-sensor-msgs \
        ros-humble-std-msgs \
        ros-humble-trajectory-msgs \
        ros-humble-control-msgs \
        ros-humble-actionlib-msgs \
        ros-humble-joint-state-publisher \
        ros-humble-robot-state-publisher \
        ros-humble-xacro \
        ros-humble-tf2 \
        ros-humble-tf2-ros \
        ros-humble-tf2-geometry-msgs \
        ros-humble-moveit \
        ros-humble-moveit-planners \
        ros-humble-moveit-simple-controller-manager \
        ros-humble-moveit-ros-planning \
        ros-humble-moveit-ros-planning-interface \
        ros-humble-moveit-ros-move-group \
        ros-humble-moveit-kinematics \
        ros-humble-moveit-servo \
        python3-colcon-common-extensions
    
    # Source ROS2 environment
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
    source /opt/ros/humble/setup.bash
    
    log "✓ ROS2 Humble installed and configured"
}

# Install Python dependencies for ArmPi Mini
install_python_dependencies() {
    log "Installing Python dependencies for ArmPi Mini and AI applications..."
    
    # Update pip
    python3 -m pip install --upgrade pip
    
    # Install core scientific computing stack
    python3 -m pip install \
        numpy \
        scipy \
        matplotlib \
        pandas \
        scikit-learn \
        scikit-image \
        pillow
    
    # Install OpenCV for computer vision
    python3 -m pip install opencv-python opencv-contrib-python
    
    # Install AI/ML libraries
    python3 -m pip install \
        tensorflow \
        torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
        mediapipe \
        ultralytics \
        transformers
    
    # Install robotics-specific Python packages
    python3 -m pip install \
        pyserial \
        gpiozero \
        RPi.GPIO \
        adafruit-circuitpython-motor \
        adafruit-circuitpython-servokit \
        modern-robotics \
        robotics-toolbox-python \
        spatialmath-python
    
    # Install communication and networking
    python3 -m pip install \
        paho-mqtt \
        flask \
        flask-socketio \
        websockets \
        requests
    
    log "✓ Python dependencies installed"
}

# Install and configure pigpio for servo control
setup_pigpio() {
    log "Installing and configuring pigpio for precise servo control..."
    
    sudo apt install -y pigpio python3-pigpio
    
    # Enable and start pigpio daemon
    sudo systemctl enable pigpiod
    sudo systemctl start pigpiod
    
    # Add user to gpio group
    sudo usermod -a -G gpio $USER
    
    log "✓ pigpio configured for servo control"
}

# Install camera support
setup_camera() {
    log "Setting up camera support for ArmPi Mini vision system..."
    
    sudo apt install -y \
        v4l-utils \
        fswebcam \
        libcamera-apps \
        libcamera-tools
    
    # Enable camera interface
    if ! grep -q "^camera_auto_detect=1" /boot/firmware/config.txt; then
        echo "camera_auto_detect=1" | sudo tee -a /boot/firmware/config.txt
    fi
    
    log "✓ Camera support configured"
}

# Install communication libraries for ArmPi Mini
install_armpi_dependencies() {
    log "Installing ArmPi Mini specific dependencies..."
    
    # Install serial communication libraries
    python3 -m pip install \
        pyserial \
        serial \
        pynput
    
    # Install servo control libraries
    python3 -m pip install \
        gpiozero \
        pigpio \
        adafruit-circuitpython-servo \
        adafruit-circuitpython-motor
    
    # Install inverse kinematics libraries
    python3 -m pip install \
        ikpy \
        robotics-toolbox-python \
        swift-sim
    
    # Install computer vision for arm control
    python3 -m pip install \
        cvzone \
        mediapipe \
        face-recognition
    
    log "✓ ArmPi Mini dependencies installed"
}

# Set up development environment
setup_dev_environment() {
    log "Setting up development environment..."
    
    # Create development directories
    mkdir -p ~/armpi_workspace
    mkdir -p ~/armpi_workspace/src
    mkdir -p ~/ros2_ws/src
    
    # Set up ROS2 workspace
    cd ~/ros2_ws
    colcon build
    echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
    
    # Create useful aliases
    cat >> ~/.bashrc << 'EOF'

# ArmPi Mini and ROS2 aliases
alias armpi-start='cd ~/armpi_workspace && python3'
alias ros2-build='cd ~/ros2_ws && colcon build'
alias ros2-source='source ~/ros2_ws/install/setup.bash'
alias start-pigpio='sudo systemctl start pigpiod'
alias stop-pigpio='sudo systemctl stop pigpiod'
alias camera-test='libcamera-hello --timeout 5000'

# Useful ROS2 shortcuts
alias ros2-topic-list='ros2 topic list'
alias ros2-node-list='ros2 node list'
alias ros2-launch='ros2 launch'
alias ros2-run='ros2 run'

EOF

    log "✓ Development environment configured"
}

# Install VNC for remote access
setup_remote_access() {
    log "Setting up VNC for remote access..."
    
    sudo apt install -y \
        realvnc-vnc-server \
        realvnc-vnc-viewer \
        xrdp
    
    # Enable VNC
    sudo systemctl enable vncserver-x11-serviced
    sudo systemctl start vncserver-x11-serviced
    
    # Configure VNC authentication
    sudo vncinitconfig
    
    log "✓ VNC remote access configured"
}

# Configure USB permissions for ArmPi Mini
setup_usb_permissions() {
    log "Configuring USB permissions for ArmPi Mini communication..."
    
    # Add user to dialout group for serial communication
    sudo usermod -a -G dialout $USER
    
    # Create udev rules for consistent device naming
    sudo tee /etc/udev/rules.d/99-armpi.rules > /dev/null << 'EOF'
# ArmPi Mini USB camera
SUBSYSTEM=="video4linux", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", MODE="0666", GROUP="video"

# ArmPi Mini serial communication
SUBSYSTEM=="tty", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", MODE="0666", GROUP="dialout"

# General USB permissions for robotics devices
SUBSYSTEM=="usb", MODE="0666", GROUP="plugdev"
EOF
    
    # Reload udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    
    log "✓ USB permissions configured"
}

# Create system optimization for robotics
optimize_system() {
    log "Optimizing system for robotics applications..."
    
    # Increase GPU memory split for camera operations
    if ! grep -q "^gpu_mem=" /boot/firmware/config.txt; then
        echo "gpu_mem=128" | sudo tee -a /boot/firmware/config.txt
    fi
    
    # Optimize for real-time performance
    echo "@realtime soft rtprio 99" | sudo tee -a /etc/security/limits.conf
    echo "@realtime hard rtprio 99" | sudo tee -a /etc/security/limits.conf
    
    # Increase swap for AI operations (if needed)
    if [ ! -f /swapfile ]; then
        sudo fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi
    
    log "✓ System optimized for robotics"
}

# Create sample ArmPi Mini test script
create_test_scripts() {
    log "Creating test scripts for ArmPi Mini verification..."
    
    # Camera test script
    cat > ~/armpi_workspace/test_camera.py << 'EOF'
#!/usr/bin/env python3
"""
ArmPi Mini Camera Test Script
Tests camera functionality and OpenCV integration
"""

import cv2
import numpy as np
import sys

def test_camera():
    print("Testing ArmPi Mini camera...")
    
    # Try to open camera
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("ERROR: Cannot open camera")
        return False
    
    # Set camera properties
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 30)
    
    print("Camera opened successfully!")
    print("Press 'q' to quit")
    
    while True:
        ret, frame = cap.read()
        
        if not ret:
            print("ERROR: Failed to capture frame")
            break
        
        # Add some basic image processing
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        edges = cv2.Canny(gray, 50, 150)
        
        # Display frame with edge detection
        cv2.imshow('ArmPi Mini Camera Test', frame)
        cv2.imshow('Edge Detection', edges)
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()
    print("Camera test completed successfully!")
    return True

if __name__ == "__main__":
    test_camera()
EOF

    # Servo test script
    cat > ~/armpi_workspace/test_servo.py << 'EOF'
#!/usr/bin/env python3
"""
ArmPi Mini Servo Test Script
Tests servo communication and basic movement
"""

import time
import serial
import sys

def test_servo_communication():
    print("Testing ArmPi Mini servo communication...")
    
    try:
        # Try common serial ports for ArmPi Mini
        ports = ['/dev/ttyUSB0', '/dev/ttyACM0', '/dev/ttyS0']
        
        for port in ports:
            try:
                print(f"Trying port: {port}")
                ser = serial.Serial(port, 9600, timeout=1)
                print(f"✓ Successfully connected to {port}")
                
                # Send test command (adjust based on ArmPi Mini protocol)
                test_command = b"#000P1500T1000!"  # Example servo command
                ser.write(test_command)
                time.sleep(1)
                
                # Read response
                response = ser.readline()
                if response:
                    print(f"Response: {response}")
                
                ser.close()
                return True
                
            except serial.SerialException:
                continue
                
        print("No ArmPi Mini device found on common ports")
        return False
        
    except Exception as e:
        print(f"Error testing servo communication: {e}")
        return False

def test_basic_movement():
    print("Testing basic servo movements...")
    print("Note: This is a template - adjust commands for your specific ArmPi Mini model")
    
    # Basic movement sequence (example)
    movements = [
        {"servo": 1, "position": 1500, "time": 1000},  # Base center
        {"servo": 2, "position": 1500, "time": 1000},  # Shoulder center
        {"servo": 3, "position": 1500, "time": 1000},  # Elbow center
        {"servo": 4, "position": 1500, "time": 1000},  # Wrist center
        {"servo": 5, "position": 1500, "time": 1000},  # Gripper center
    ]
    
    for move in movements:
        print(f"Moving servo {move['servo']} to position {move['position']}")
        # Implement actual servo control here
        time.sleep(1)
    
    print("Basic movement test completed!")

if __name__ == "__main__":
    if test_servo_communication():
        test_basic_movement()
    else:
        print("Servo communication test failed")
        sys.exit(1)
EOF

    # ROS2 integration test
    cat > ~/armpi_workspace/test_ros2_integration.py << 'EOF'
#!/usr/bin/env python3
"""
ArmPi Mini ROS2 Integration Test
Tests ROS2 nodes and basic arm control
"""

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import JointState
from geometry_msgs.msg import Pose
import numpy as np

class ArmPiTestNode(Node):
    def __init__(self):
        super().__init__('armpi_test_node')
        
        # Publishers
        self.joint_pub = self.create_publisher(JointState, 'joint_states', 10)
        
        # Subscribers  
        self.pose_sub = self.create_subscription(
            Pose, 'target_pose', self.pose_callback, 10)
        
        # Timer for publishing joint states
        self.timer = self.create_timer(0.1, self.publish_joint_states)
        
        self.get_logger().info('ArmPi Mini ROS2 test node started')
        
        # Initialize joint positions
        self.joint_positions = [0.0, 0.0, 0.0, 0.0, 0.0]
        self.joint_names = ['base_joint', 'shoulder_joint', 'elbow_joint', 
                           'wrist_joint', 'gripper_joint']
    
    def publish_joint_states(self):
        """Publish current joint states"""
        msg = JointState()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.name = self.joint_names
        msg.position = self.joint_positions
        msg.velocity = [0.0] * len(self.joint_names)
        msg.effort = [0.0] * len(self.joint_names)
        
        self.joint_pub.publish(msg)
    
    def pose_callback(self, msg):
        """Handle target pose commands"""
        self.get_logger().info(f'Received target pose: x={msg.position.x:.2f}, '
                              f'y={msg.position.y:.2f}, z={msg.position.z:.2f}')
        
        # Here you would implement inverse kinematics
        # For now, just log the received pose
        
def main(args=None):
    rclpy.init(args=args)
    
    node = ArmPiTestNode()
    
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
EOF

    # Make scripts executable
    chmod +x ~/armpi_workspace/test_*.py
    
    log "✓ Test scripts created in ~/armpi_workspace/"
}

# Create systemd service for auto-starting ArmPi Mini
create_systemd_service() {
    log "Creating systemd service for ArmPi Mini auto-start..."
    
    sudo tee /etc/systemd/system/armpi-mini.service > /dev/null << 'EOF'
[Unit]
Description=ArmPi Mini Robotic Arm Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/armpi_workspace
ExecStart=/usr/bin/python3 /home/ubuntu/armpi_workspace/armpi_main.py
Restart=always
RestartSec=5
Environment=PYTHONPATH=/home/ubuntu/armpi_workspace
Environment=ROS_DOMAIN_ID=0

[Install]
WantedBy=multi-user.target
EOF

    # Create placeholder main script
    cat > ~/armpi_workspace/armpi_main.py << 'EOF'
#!/usr/bin/env python3
"""
ArmPi Mini Main Service Script
Replace this with your actual ArmPi Mini control software
"""

import time
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def main():
    logging.info("ArmPi Mini service starting...")
    
    try:
        while True:
            # Your ArmPi Mini control logic goes here
            logging.info("ArmPi Mini running...")
            time.sleep(10)
            
    except KeyboardInterrupt:
        logging.info("ArmPi Mini service stopping...")
    except Exception as e:
        logging.error(f"ArmPi Mini error: {e}")

if __name__ == "__main__":
    main()
EOF

    chmod +x ~/armpi_workspace/armpi_main.py
    
    # Enable but don't start the service (user can start when ready)
    sudo systemctl daemon-reload
    
    log "✓ Systemd service created (use 'sudo systemctl enable armpi-mini' to enable)"
}

# Main installation function
main() {
    echo "========================================"
    echo "  Raspberry Pi 5 ArmPi Mini Setup"
    echo "========================================"
    echo ""
    echo "This script will install and configure:"
    echo "• ROS2 Humble Hawksbill"
    echo "• OpenCV and Computer Vision libraries"
    echo "• AI/ML libraries (TensorFlow, PyTorch, MediaPipe)"
    echo "• ArmPi Mini robotic arm dependencies"
    echo "• Development tools and environment"
    echo ""
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
    
    log "Starting Raspberry Pi 5 ArmPi Mini setup..."
    
    # Check system compatibility
    check_rpi5
    check_ubuntu
    
    # Core system setup
    update_system
    install_development_tools
    setup_locale
    
    # ROS2 installation
    install_ros2
    
    # Python and AI libraries
    install_python_dependencies
    
    # ArmPi Mini specific setup
    install_armpi_dependencies
    setup_pigpio
    setup_camera
    setup_usb_permissions
    
    # Development environment
    setup_dev_environment
    setup_remote_access
    
    # System optimization
    optimize_system
    
    # Create test scripts and services
    create_test_scripts
    create_systemd_service
    
    log "=========================================="
    log "Installation completed successfully!"
    log "=========================================="
    
    info "Next steps:"
    echo "1. Reboot your Raspberry Pi 5:"
    echo "   sudo reboot"
    echo ""
    echo "2. Test camera functionality:"
    echo "   python3 ~/armpi_workspace/test_camera.py"
    echo ""
    echo "3. Test servo communication:"
    echo "   python3 ~/armpi_workspace/test_servo.py"
    echo ""
    echo "4. Test ROS2 integration:"
    echo "   source ~/.bashrc"
    echo "   python3 ~/armpi_workspace/test_ros2_integration.py"
    echo ""
    echo "5. For ROS2 development:"
    echo "   cd ~/ros2_ws"
    echo "   colcon build"
    echo "   source install/setup.bash"
    echo ""
    echo "6. Enable ArmPi Mini auto-start (optional):"
    echo "   sudo systemctl enable armpi-mini"
    echo ""
    
    warn "IMPORTANT: A reboot is required to complete the setup!"
    warn "Run 'sudo reboot' when ready."
}

# Run main function
main "$@"