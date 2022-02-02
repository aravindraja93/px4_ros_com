#!/bin/bash

source /opt/ros/galactic/setup.bash

micrortps_agent -t UDP -n "$DRONE_DEVICE_ID"
