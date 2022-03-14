@###############################################
@#
@# EmPy template for generating <msg>_uRTPS_UART.cpp file
@#
@###############################################
@# Start of Template
@#
@# Context:
@#  - fastrtps_version (str) FastRTPS version installed on the system
@#  - ros2_distro (str) ROS2 distro name
@#  - spec (msggen.MsgSpec) Parsed specification of the .msg file
@###############################################
@{
import genmsg.msgs
from packaging import version
import re

topic = alias if alias else spec.short_name

try:
    ros2_distro = ros2_distro.decode("utf-8")
except AttributeError:
    pass

topic_name = topic

# For ROS, use the topic pattern convention defined in
# http://wiki.ros.org/ROS/Patterns/Conventions
if ros2_distro:
    topic_name_split = re.sub( r"([A-Z])", r" \1", topic).split()
    topic_name = topic_name_split[0]
    for w in topic_name_split[1:]:
        topic_name += "_" + w
    topic_name = topic_name.lower()
}@
/****************************************************************************
 *
 * Copyright 2017 Proyectos y Sistemas de Mantenimiento SL (eProsima).
 * Copyright (c) 2018-2021 PX4 Development Team. All rights reserved.
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

/*!
 * @@file @(topic)_Publisher.cpp
 * This file contains the implementation of the publisher functions.
 *
 * This file was adapted from the fastrtpsgen tool.
 */

#include "@(topic)_Publisher.h"

#include <fastdds/dds/domain/DomainParticipantFactory.hpp>
#include <fastdds/dds/topic/TypeSupport.hpp>
#include <fastdds/dds/publisher/Publisher.hpp>
#include <fastdds/rtps/transport/UDPv4TransportDescriptor.h>

using UDPv4TransportDescriptor = eprosima::fastdds::rtps::UDPv4TransportDescriptor;


@[if version.parse(fastrtps_version) >= version.parse('2.0')]@
#include <fastdds/rtps/transport/shared_mem/SharedMemTransportDescriptor.h>

using SharedMemTransportDescriptor = eprosima::fastdds::rtps::SharedMemTransportDescriptor;
@[end if]@

@(topic)_Publisher::@(topic)_Publisher()
	: mp_participant(nullptr),
	  mp_topic(nullptr),
	  mp_writer(nullptr),
	  mp_type(new @(topic)_msg_datatype())

{ }

@(topic)_Publisher::~@(topic)_Publisher()
{
	if (mp_writer != nullptr)
	{
		mp_publisher->delete_datawriter(mp_writer);
	}
	if (mp_publisher != nullptr)
	{
		mp_participant->delete_publisher(mp_publisher);
	}
	if (mp_topic != nullptr)
	{
		mp_participant->delete_topic(mp_topic);
	}
	DomainParticipantFactory::get_instance()->delete_participant(mp_participant);
}

bool @(topic)_Publisher::init(const std::string &ns, const std::vector<std::string>& whitelist, std::string topic_name)
{

	// Create DomainParticipant
	DomainParticipantQos participantQos;
	std::string nodeName = ns;
	nodeName.append("@(topic)_publisher");

	// Create a descriptor for the new transport.
	auto udp_transport = std::make_shared<UDPv4TransportDescriptor>();

	if (!whitelist.empty()) {
		udp_transport->interfaceWhiteList = whitelist;
	}

	// Link the Transport Layer to the Participant.
	participantQos.transport().user_transports.push_back(udp_transport);

	// Avoid using the default transport
	participantQos.transport().use_builtin_transports = false;

	participantQos.name(nodeName.c_str());
	mp_participant = DomainParticipantFactory::get_instance()->create_participant(0, participantQos);

	if (mp_participant == nullptr) {
		return false;
	}

	// Register the type
	mp_type.register_type(mp_participant);

	// Create the publications Topic
	std::string topicName = "rt/"; // Indicate ROS2 that this is user topic
	topicName.append(ns);
	topic_name.empty() ? topicName.append("fmu/@(topic_name)/out") : topicName.append(topic_name);
	mp_topic = mp_participant->create_topic(topicName.c_str(), mp_type.get_type_name(), TOPIC_QOS_DEFAULT);
	if(mp_topic == nullptr)
		return false;

	// Create the Publisher
	mp_publisher = mp_participant->create_publisher(PUBLISHER_QOS_DEFAULT, nullptr);
	if (mp_publisher == nullptr) {
		return false;
	}

	// Create the DataWriter
	mp_writer = mp_publisher->create_datawriter(mp_topic, DATAWRITER_QOS_DEFAULT, &m_listener);
	if (mp_writer == nullptr)
	{
		return false;
	}

	return true;
}

void @(topic)_Publisher::PubListener::on_publication_matched(DataWriter*,
		const PublicationMatchedStatus& info)
{
	if (info.current_count_change == 1)
	{
		n_matched = info.total_count;
		std::cout << "\033[0;37m[   micrortps_agent   ]\t@(topic) publisher matched\033[0m" << std::endl;
	}
	else if (info.current_count_change == -1)
	{
		n_matched = info.total_count;
		std::cout << "\033[0;37m[   micrortps_agent   ]\t@(topic) publisher unmatched\033[0m" << std::endl;
	}
	else
	{
		std::cout << "\033[0;37m[   micrortps_agent   ]\t @(topic) publisher: " << info.current_count_change
			<< " is not a valid value for PublicationMatchedStatus current count change.\033[0m" << std::endl;
	}
}

void @(topic)_Publisher::publish(@(topic)_msg_t *st)
{
	if (m_listener.n_matched > 0)
	{
		mp_writer->write(st);
	}
}
