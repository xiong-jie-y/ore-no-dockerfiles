# What is it?
This is a dockerfile for [OV^2 SLAM](https://github.com/ov2slam/ov2slam).

To build the docker image, run

```
docker build  --rm -t ov2slam .
```

## How to run SLAM?
To run the docker.

```
docker run --gpus all --shm-size=8g -v `pwd`:/data -e QT_X11_NO_MITSHM=1 -e LOCAL_UID=$(id -u $USER)  -e LOCAL_GID=$(id -g $USER) --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY  -it ov2slam bash
```

This shell should be used to run the rviz, so we need open other shells to run roscore, rosbag player, slam.
Run two more other shells by

```shell
docker exec -it ${CONTAINER_ID} bash
```

The container id is hostname of the shell.

shell1
```bash 
roscore &

cd /workspace/catkin_ws
rosrun ov2slam ov2slam_node src/ov2slam/parameters_files/fast/euroc/euroc_mono.yaml
```

shell2
```bash
cd /workspace/catkin_ws
rosrun rviz rviz -d src/ov2slam/ov2slam_visualization.rviz
```

And then run rosbag reader to feed the data to ov^2 slam.