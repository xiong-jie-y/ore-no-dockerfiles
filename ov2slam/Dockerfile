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


RUN apt update && apt install ros-melodic-desktop-full -y

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y && \
    apt install python-rosdep -y
SHELL ["/bin/bash", "-c"]
RUN source ~/.bashrc && rosdep init && rosdep update
RUN mkdir -p /workspace/catkin_ws/src

SHELL ["/bin/bash", "-c"]
RUN cat /opt/ros/melodic/setup.bash && source /opt/ros/melodic/setup.bash && source ~/.bashrc && cd /workspace/catkin_ws/ &&  catkin_make

# -- opencv installation (because opencv-contrib is needed.)

# opencv dependencies.
RUN apt -y install build-essential checkinstall cmake pkg-config yasm git gfortran libjpeg8-dev libpng-dev &&  \
    apt -y install software-properties-common && \
    add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" &&  \
    apt -y update &&  \
    apt -y install libjasper1 && \
    apt -y install libtiff-dev && \
    apt -y install libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev && \
    apt -y install libxine2-dev libv4l-dev && \
    cd /usr/include/linux && \
    sudo ln -s -f ../libv4l1-videodev.h videodev.h && \
    cd "$cwd" && \

    apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev && \
    apt -y install libgtk2.0-dev libtbb-dev qt5-default && \
    apt -y install libatlas-base-dev && \
    apt -y install libfaac-dev libmp3lame-dev libtheora-dev && \
    apt -y install libvorbis-dev libxvidcore-dev && \
    apt -y install libopencore-amrnb-dev libopencore-amrwb-dev && \
    apt -y install libavresample-dev && \
    apt -y install x264 v4l-utils && \

    # ional dependencies
    apt -y install libprotobuf-dev protobuf-compiler && \
    apt -y install libgoogle-glog-dev libgflags-dev && \
    apt -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen

RUN cd ~/ && \
    git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 3.2.0

RUN cd ~/ && \ 
    git clone https://github.com/opencv/opencv_contrib.git && \
    cd opencv_contrib && \ 
    git checkout 3.2.0

RUN  apt install build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-22-dev -y

RUN cd ~/opencv && \
    mkdir build && \
    cd build && \ 
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D WITH_CUDA=OFF \
        -D CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT=ON \
        -DENABLE_PRECOMPILED_HEADERS=OFF \ 
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON .. && \
    make -j && \
    make install && \
    sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf' && \
    ldconfig

# Install OpenGV.
RUN git clone https://github.com/laurentkneip/opengv && \
    apt-get install build-essential cmake libeigen3-dev && \
    cd ./opengv && \
    mkdir build && cd build && cmake .. && make -j && make install

RUN source ~/.bashrc &&  \
    cd /workspace/catkin_ws/ &&  \
    source devel/setup.sh &&  \
    cd /workspace/catkin_ws/src &&  \
    git clone https://github.com/ov2slam/ov2slam.git &&  \
    cd /workspace/catkin_ws/src/ov2slam && \
    sed -i 's/ptr = cv_bridge::toCvCopy(img_msg);/ptr = cv_bridge::toCvCopy(img_msg, "mono8");/g' src/ov2slam_node.cpp

RUN cd /workspace/catkin_ws/src/ov2slam && \
    chmod +x build_thirdparty.sh && \
    ./build_thirdparty.sh

# Recompile this need to be merged to earlier.
# This is doing forcefully does cmake again.
RUN cd /workspace/catkin_ws/ && \
    source /opt/ros/melodic/setup.bash && \
    catkin_make --force-cmake --pkg ov2slam && \
    source /workspace/catkin_ws/devel/setup.bash

# Some config for user.
RUN apt-get install -y gosu 
RUN apt install emacs -y

# Patch for paramter file.
RUN echo "source /workspace/catkin_ws/devel/setup.bash" >> ~/.bashrc

COPY calibration_param_change.patch /workspace/calibration_param_change.patch
RUN cd /workspace/catkin_ws/src/ov2slam && \
    patch -p 1 < /workspace/calibration_param_change.patch

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
