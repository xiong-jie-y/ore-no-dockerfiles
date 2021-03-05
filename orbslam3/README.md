# Briefing
You can build docker image that 

- can run [ORB-SLAM3](https://github.com/UZ-SLAMLab/ORB_SLAM3).

## How to build and run
To build the image, just run.

```
docker build  --rm -t orb-slam3 .\
```

To run the docker run the following command.

```bash
docker run --gpus all --shm-size=8g -v `pwd`:/workspace/work \
     -e LOCAL_UID=$(id -u $USER)  -e LOCAL_GID=$(id -g $USER) \
     --privileged \
     --env="QT_X11_NO_MITSHM=1"  -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY \
     -it orb-slam3 bash
```

To run it, please check the [README.md](https://github.com/UZ-SLAMLab/ORB_SLAM3)
