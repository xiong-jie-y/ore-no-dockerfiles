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

# Some config for user.
RUN apt-get install -y gosu 
RUN apt install emacs -y

# This specific config for user.
RUN apt-get install ffmpeg -y

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]