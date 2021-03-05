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

# -- ROS realsense

# for add-apt-repository.
RUN apt-get install software-properties-common -y

# realsense sdk
RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE && \
    add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" -u && \
    apt-get install librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg -y

# realsense wrapper dependency.
RUN apt install ros-melodic-ddynamic-reconfigure

# realsense wrapper.
RUN source /opt/ros/melodic/setup.bash && \ 
    source /workspace/catkin_ws/devel/setup.bash && \
    cd /workspace/catkin_ws/src/ && \
    git clone https://github.com/IntelRealSense/realsense-ros.git && \
    cd realsense-ros/ && \
    git checkout `git tag | sort -V | grep -P "^2.\d+\.\d+" | tail -1` && \
    cd ../../ && \
    catkin_make -DCATKIN_ENABLE_TESTING=False -DCMAKE_BUILD_TYPE=Release && \
    catkin_make install

# -- install Patagolin, whcih is required by ORB-SLAM3.

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

# -- install opencv, which is a dependency for ORB-SLAM3.

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

# Python
RUN apt install python-pip libpython2.7-dev -y && \
    python -m pip install numpy

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

# Build dependencies.
RUN  source /opt/ros/melodic/setup.bash && cd /workspace/catkin_ws/src && \
    git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git ORB_SLAM3 && \
    cd ORB_SLAM3 && \
    chmod +x build.sh && \
    ./build.sh

# Build for ROS.
RUN source /opt/ros/melodic/setup.bash && cd /workspace/catkin_ws/src && \
    cd /workspace/catkin_ws/src/ORB_SLAM3 && \
    export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/workspace/catkin_ws/src/ORB_SLAM3/Examples/ROS && \
    chmod +x build_ros.sh && ./build_ros.sh

# Some config for user.
RUN apt-get install -y gosu 
RUN apt install emacs -y

# This specific config for user.
RUN apt-get install ffmpeg -y

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]