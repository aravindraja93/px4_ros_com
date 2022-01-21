#!/bin/bash

source /opt/ros/galactic/setup.bash
export FASTRTPS_DEFAULT_PROFILES_FILE=/opt/ros/galactic/DEFAULT_FASTRTPS_PROFILES.xml

micrortps_agent -t UDP -n "$DRONE_DEVICE_ID" -b 1000000
