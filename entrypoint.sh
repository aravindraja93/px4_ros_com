#!/bin/bash

source /opt/ros/foxy/setup.bash

micrortps_agent -t UDP -n "$DRONE_DEVICE_ID"
