FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu18.04

# ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND teletype
ENV ACCEPT_EULA y

RUN apt update && \

apt-get install cmake libeigen3-dev libboost-dev libboost-filesystem-dev libboost-graph-dev libboost-system-dev libopencv-dev -y

RUN apt-get install git wget -y

RUN git clone https://github.com/NVlabs/intrinsic3d.git && \
    cd intrinsic3d && \
    mkdir third_party && cd third_party && \
    apt-get install libgoogle-glog-dev libatlas-base-dev libsuitesparse-dev -y && \
    wget http://ceres-solver.org/ceres-solver-1.14.0.tar.gz && \
    tar xvzf ceres-solver-1.14.0.tar.gz && \
    cd ceres-solver-1.14.0 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/../../ -DCXX11=ON -DSUITESPARSE=ON -DCXSPARSE=ON -DEIGENSPARSE=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF && \
    make -j && \
    make install

RUN cd intrinsic3d && mkdir build && cd build && \
    cmake .. -DCeres_DIR=$PWD/../third_party/lib/cmake/Ceres && \
    make -j

# Some config for user.
RUN apt-get install -y gosu 
RUN apt install emacs -y

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]