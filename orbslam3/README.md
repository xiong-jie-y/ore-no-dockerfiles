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

### Example: SLAM with Realsense D435i
1. Make a configuration file. you can use `src/ORB_SLAM3/Examples/RGB-D/TUM1.yaml` as a template. Edit the camera intrinsic parameter.

Here's the my realsense d435i camera intrinsic from Open3D's realsense_recorder. Als I prepared patch `realsense_intrinsic_patch.patch`.

```json
{
    "width": 640,
    "height": 480,
    "intrinsic_matrix": [
        612.6339111328125,
        0,
        0,
        0,
        611.052734375,
        0,
        327.3898010253906,
        253.2864227294922,
        1
    ]
}
```

2. Run the roscore in one terminal launch the new one.

```
docker exec --user user -it ${DOCKER_CONTAINER_ID} bash
roscore
```

3. Run the orb-slam3. The depth/rgb topic from the realsense wrapper is different from the orb-slam3's one. so please remap it with the argument.

```
docker exec --user user -it ${DOCKER_CONTAINER_ID} bash

rosrun ORB_SLAM3 RGBD src/ORB_SLAM3/Vocabulary/ORBvoc.txt src/ORB_SLAM3/Examples/RGB-D/TUM1.yaml /camera/rgb/image_raw:=/camera/color/image_raw /camera/depth_registered/image_raw:=/camera/depth/image_rect_raw
```


4. Run the camera stream. Please carefully choose launch file if you want to use different realsense sensor. The parameter config is in the `realsense_config.patch`

```
docker exec --user user -it ${DOCKER_CONTAINER_ID} bash

roslaunch realsense2_camera rs_d435_camera_with_model.launch
```

1. (Optional) This is the example to play rosbag instead of live camera.

```
rosbag play --pause /workspace/work/realsense_640x480.bag /device_0/sensor_1/Color_0/image/data:=/camera/rgb/image_raw /device_0/sensor_0/Depth_0/image/data:=/camera/depth_registered/image_raw
```