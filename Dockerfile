FROM ghcr.io/tiiuae/fog-ros-baseimage:builder-2f516bb AS builder

# TODO: should these be in the base image?
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python3-genmsg \
    openjdk-11-jdk-headless \
    fast-dds-gen \
    && rm -rf /var/lib/apt/lists/*

COPY . /main_ws/src/

# this:
# 1) builds the application
# 2) packages the application as .deb, writes it to /main_ws/
RUN /packaging/build.sh

#  ▲               runtime ──┐
#  └── build                 ▼

FROM ghcr.io/tiiuae/fog-ros-baseimage:sha-2f516bb

ENTRYPOINT /entrypoint.sh

COPY entrypoint.sh /entrypoint.sh

COPY --from=builder /main_ws/ros-*-px4-ros-com_*_amd64.deb /px4-ros-com.deb

# need update because ROS people have a habit of removing old packages pretty fast
RUN apt update && apt install -y libeigen3-dev ros-${ROS_DISTRO}-eigen3-cmake-module \
	&& dpkg -i /px4-ros-com.deb && rm /px4-ros-com.deb
