FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu18.04

# -- General configuration

# Prevent apt installation stop by EURO agreement.
ENV DEBIAN_FRONTEND teletype
ENV ACCEPT_EULA y

# To enable OPENGL window open in host side.
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# -- ROS installation

# For lsb_release
RUN apt-get update && apt-get install -y lsb-release && apt-get clean all

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654


# ROS installation and ws preparation.
RUN apt update && apt install ros-melodic-desktop-full -y

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y && \
    apt install python-rosdep -y
SHELL ["/bin/bash", "-c"]
RUN source ~/.bashrc && rosdep init && rosdep update


RUN mkdir -p /workspace/catkin_ws/src

SHELL ["/bin/bash", "-c"]
RUN cat /opt/ros/melodic/setup.bash && source /opt/ros/melodic/setup.bash && source ~/.bashrc && cd /workspace/catkin_ws/ &&  catkin_make

# g2o installation.
RUN apt install cmake libeigen3-dev -y
RUN apt install libsuitesparse-dev qtdeclarative5-dev qt5-qmake libqglviewer-dev-qt5 -y
RUN git clone https://github.com/RainerKuemmerle/g2o.git && \
    cd g2o && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make install

# DOW2
RUN git clone https://github.com/shinsumicco/DBoW2.git && \
    cd DBoW2 && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make install

# -- install Patagolin, whcih is required by iris.

# Pangolin Dependencies.
RUN apt install libgl1-mesa-dev -y && \
    apt install libglew-dev -y && \
    apt install cmake -y

# Pangolin installation.
RUN git clone https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . && make install


# iris installation.
RUN source /opt/ros/melodic/setup.bash && \
    cd /workspace/catkin_ws/src && \
    git clone --recursive https://github.com/MapIV/iris.git  && \
    cd .. && \
    sed  -i '1i #include <iomanip>' src/iris/openvslam_bridge/3rd/openvslam/src/openvslam/publish/frame_publisher.cc && \
    catkin_make

# Some config for user.
RUN apt-get install -y gosu 
RUN apt install emacs -y

# This specific config for user.
RUN apt-get install ffmpeg -y

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]