#!/bin/bash -e

# TODO: is this only used for setting $DRONE_DEVICE_ID ?
source /opt/ros/${ROS_DISTRO}/setup.bash

if [[ ! "${DRONE_DEVICE_ID:-}" ]]; then
	echo "[ERROR] DRONE_DEVICE_ID not set"
	exit 1
fi

if [ "${FLIGHT_CONTROLLER_DIRECT_ETH}" != "" ]; then
  # Direct ethernet connection to FC
  exec micrortps_agent -t UDP -b 10000000 -i 192.168.200.100 -n "$DRONE_DEVICE_ID"
else
  # FC connection via protocol_splitter/UART
  exec micrortps_agent -t UDP -b 2000000 -n "$DRONE_DEVICE_ID"
fi
