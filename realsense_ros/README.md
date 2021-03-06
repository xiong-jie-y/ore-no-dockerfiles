# Briefing
You can build docker image that 

- can run realsense ros node
- can run rviz
- can run ffplay camera input

You can copy and paste from this Dockerfile.

## How to build and run

To build the image, just run.

```
docker build  --rm -t ros-realsense .
```

To run the docker run the following command.
3rd line is for accessing the realsense device.
4th line is for allowing the UI to be shown on host.

```bash
docker run --gpus all --shm-size=8g -v `pwd`:/workspace/work \
     -e LOCAL_UID=$(id -u $USER)  -e LOCAL_GID=$(id -g $USER) \
     --privileged \
     --env="QT_X11_NO_MITSHM=1"  -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \
     -it ros-realsense bash
```

