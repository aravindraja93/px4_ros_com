#!/bin/bash -e

source /opt/ros/galactic/setup.bash

if [ "${FLIGHT_CONTROLLER_DIRECT_ETH}" != "" ]; then
  # Direct ethernet connection to FC
  exec micrortps_agent -t UDP -b 10000000 -i 192.168.200.101 -n "$DRONE_DEVICE_ID"
else
  # FC connection via protocol_splitter/UART
  exec micrortps_agent -t UDP -b 2000000 -i 192.168.200.100  -n "$DRONE_DEVICE_ID"
fi
