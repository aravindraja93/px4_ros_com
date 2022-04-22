#!/bin/bash -e

# Build docker image that generates and store debian package
docker build -t px4_ros_com -f Dockerfile.deb .

# Create temp container from generated docker image
docker create --name tmp_cont1 px4_ros_com > /dev/null
# Copy artifacts folder containing debian package to current workdir.
#  There is no wildcard option possible in 'docker cp' to copy deb file
#  without need to know the exact name, so need to copy the whole directory
docker cp tmp_cont1:/deb_file .

# Print debian package name
echo
echo "Debian package:"
ls ./deb_file
echo

# Copy debian package from artifacts directory to current workdir
cp ./deb_file/*.deb .

# Cleanup
#   Remove tmp artifact folder
rm -Rf ./deb_file
#   Remove docker container created from generated image for copying the debian package
docker rm tmp_cont1 > /dev/null
