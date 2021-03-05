#!/bin/bash

USER_ID=${LOCAL_UID:-62000}
GROUP_ID=${LOCAL_GID:-62000}

echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
useradd -u $USER_ID -o -m user
groupmod -g $GROUP_ID user
export HOME=/home/user

echo "source /opt/ros/melodic/setup.bash" >> /home/user/.bashrc
echo "source /workspace/catkin_ws/devel/setup.bash" >> /home/user/.bashrc

chown -R user:user /workspace/catkin_ws
chown -R user:user /home/user/.bashrc

exec /usr/sbin/gosu user "$@"