FROM ghcr.io/tiiuae/fog-ros-baseimage:builder-latest AS builder

# TODO: should these be in the base image?
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python3-genmsg \
    openjdk-11-jdk-headless \
    fast-dds-gen \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://ssrc.jfrog.io/artifactory/ssrc-debian-public-remote-cache/ros-galactic-px4-msgs_4.0.0-25~git20220422.0f07b25_amd64.deb -O /px4-msgs.deb \
  && dpkg -i /px4-msgs.deb

COPY . /main_ws/src/

# this:
# 1) builds the application
# 2) packages the application as .deb, writes it to /main_ws/
RUN /packaging/build.sh

#  ▲               runtime ──┐
#  └── build                 ▼

FROM ghcr.io/tiiuae/fog-ros-baseimage:stable

ENTRYPOINT /entrypoint.sh

COPY entrypoint.sh /entrypoint.sh

COPY --from=build /px4-msgs.deb .
RUN dpkg -i px4-msgs.deb && rm px4-msgs.deb

COPY --from=builder /main_ws/ros-*-px4-ros-com_*_amd64.deb /px4-ros-com.deb

# need update because ROS people have a habit of removing old packages pretty fast
RUN apt update && apt install -y libeigen3-dev ros-${ROS_DISTRO}-eigen3-cmake-module \
	&& dpkg -i /px4-ros-com.deb && rm /px4-ros-com.deb
