/****************************************************************************
 *
 * Copyright 2019 PX4 Development Team. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

/**
 * @brief Vehicle GPS position uORB topic listener example
 * @file vehicle_global_position_listener.cpp
 * @addtogroup examples
 * @author Nuno Marques <nuno.marques@dronesolutions.io>
 */

#include <rclcpp/rclcpp.hpp>
#include <px4_msgs/msg/vehicle_global_position.hpp>

/**
 * @brief Vehicle GPS position uORB topic data callback
 */
class VehicleGlobalPositionListener : public rclcpp::Node
{
public:
	explicit VehicleGlobalPositionListener() : Node("vehicle_global_position_listener") {
		subscription_ = this->create_subscription<px4_msgs::msg::VehicleGlobalPosition>(
			"fmu/vehicle_global_position/out",
#ifdef ROS_DEFAULT_API
            10,
#endif
			[this](const px4_msgs::msg::VehicleGlobalPosition::UniquePtr msg) {
			std::cout << "\n\n\n\n\n\n\n\n\n\n";
			std::cout << "RECEIVED VEHICLE POSITION DATA"   << std::endl;
			std::cout << "=================================="   << std::endl;
			std::cout << "ts: "      << msg->timestamp    << std::endl;
			std::cout << "lat: " << msg->lat  << std::endl;
			std::cout << "lon: " << msg->lon << std::endl;
			std::cout << "alt: " << msg->alt  << std::endl;
			std::cout << "alt_ellipsoid: " << msg->alt_ellipsoid << std::endl;
			std::cout << "delta_alt: " << msg->delta_alt << std::endl;
			std::cout << "lat_lon_reset_counter: " << msg->lat_lon_reset_counter << std::endl;
			std::cout << "alt_reset_counter: " << msg->alt_reset_counter << std::endl;
			std::cout << "eph: " << msg->eph << std::endl;
			std::cout << "epv: " << msg->epv << std::endl;
			std::cout << "terrain_alt: " << msg->terrain_alt << std::endl;
			std::cout << "terrain_alt_valid: " << msg->terrain_alt_valid << std::endl;
			std::cout << "dead_reckoning: " << msg->dead_reckoning << std::endl;

		});
	}

private:
	rclcpp::Subscription<px4_msgs::msg::VehicleGlobalPosition>::SharedPtr subscription_;
};

int main(int argc, char *argv[])
{
	std::cout << "Starting vehicle_global_position listener node..." << std::endl;
	setvbuf(stdout, NULL, _IONBF, BUFSIZ);
	rclcpp::init(argc, argv);
	rclcpp::spin(std::make_shared<VehicleGlobalPositionListener>());

	rclcpp::shutdown();
	return 0;
}
