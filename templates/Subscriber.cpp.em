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
 * @@file @(topic)_Subscriber.cpp
 * This file contains the implementation of the subscriber functions.
 *
 * This file was adapted from the fastrtpsgen tool.
 */

#include "@(topic)_Subscriber.h"

#include <fastdds/dds/domain/DomainParticipantFactory.hpp>
#include <fastdds/dds/topic/TypeSupport.hpp>
#include <fastdds/dds/subscriber/Subscriber.hpp>
#include <fastdds/dds/subscriber/qos/DataReaderQos.hpp>
#include <fastdds/dds/subscriber/SampleInfo.hpp>
#include <fastdds/rtps/transport/UDPv4TransportDescriptor.h>

using UDPv4TransportDescriptor = eprosima::fastdds::rtps::UDPv4TransportDescriptor;

@[if version.parse(fastrtps_version) >= version.parse('2.0')]@
#include <fastdds/rtps/transport/shared_mem/SharedMemTransportDescriptor.h>

using SharedMemTransportDescriptor = eprosima::fastdds::rtps::SharedMemTransportDescriptor;
@[end if]@


@(topic)_Subscriber::@(topic)_Subscriber()
	: mp_participant(nullptr),
	  mp_subscriber(nullptr),
	  mp_reader(nullptr),
	  mp_topic(nullptr),
	  mp_type(new @(topic)_msg_datatype())
{ }

@(topic)_Subscriber::~@(topic)_Subscriber()
{
	if (mp_reader != nullptr)
	{
		mp_subscriber->delete_datareader(mp_reader);
	}
	if (mp_topic != nullptr)
	{
		mp_participant->delete_topic(mp_topic);
	}
	if (mp_subscriber != nullptr)
	{
		mp_participant->delete_subscriber(mp_subscriber);
	}
	DomainParticipantFactory::get_instance()->delete_participant(mp_participant);
}

bool @(topic)_Subscriber::init(uint8_t topic_ID, std::condition_variable *t_send_queue_cv,
			       std::mutex *t_send_queue_mutex, std::queue<uint8_t> *t_send_queue, const std::string &ns,
			       const std::vector<std::string>& whitelist, std::string topic_name)
{
	m_listener.topic_ID = topic_ID;
	m_listener.t_send_queue_cv = t_send_queue_cv;
	m_listener.t_send_queue_mutex = t_send_queue_mutex;
	m_listener.t_send_queue = t_send_queue;

	// Create Participant
	std::string nodeName = ns;
	nodeName.append("@(topic)_subscriber");
	DomainParticipantQos participantQos;
	participantQos.name(nodeName.c_str());

	// Create a descriptor for the new transport.
	auto udp_transport = std::make_shared<UDPv4TransportDescriptor>();

	if (!whitelist.empty()) {
		udp_transport->interfaceWhiteList = whitelist;
	}
	// Link the Transport Layer to the Participant.
	participantQos.transport().user_transports.push_back(udp_transport);

	// Avoid using the default transport
	participantQos.transport().use_builtin_transports = false;

	mp_participant = DomainParticipantFactory::get_instance()->create_participant(0, participantQos);
	if (mp_participant == nullptr) {
		return false;
	}

	// Register the type
	mp_type.register_type(mp_participant);

	// Create subscription topic
	std::string topicName = "rt/";
	topicName.append(ns);
	topic_name.empty() ? topicName.append("fmu/@(topic_name)/in") : topicName.append(topic_name);
	mp_topic = mp_participant->create_topic(topicName.c_str(), mp_type.get_type_name(), TOPIC_QOS_DEFAULT);
	if (mp_topic == nullptr)
	{
		return false;
	}

	// Create Subscriber
	mp_subscriber = mp_participant->create_subscriber(SUBSCRIBER_QOS_DEFAULT, nullptr);
	if (mp_subscriber == nullptr)
	{
		return false;
	}

	// Create the DataReader
	mp_reader = mp_subscriber->create_datareader(mp_topic, DATAREADER_QOS_DEFAULT, &m_listener);
	if (mp_reader == nullptr)
	{
		return false;
	}

	return true;
}

void @(topic)_Subscriber::SubListener::on_subscription_matched(DataReader*,
		const SubscriptionMatchedStatus& info)
{
@# Since the time sync runs on the bridge itself, it is required that there is a
@# match between two topics of the same entity
@[if topic != 'Timesync' and topic != 'timesync' and topic != 'TimesyncStatus' and topic != 'timesync_status']@
	if (info.current_count_change == 1)
	{
		n_matched = info.total_count;
		std::cout << "\033[0;37m[   micrortps_agent   ]\t@(topic) subscriber matched\033[0m" << std::endl;
	}

	else if (info.current_count_change == -1)
	{
		n_matched = info.total_count;
		std::cout << "\033[0;37m[   micrortps_agent   ]\t@(topic) subscriber unmatched\033[0m" << std::endl;
	}
	else
	{
		std::cout << "\033[0;37m[   micrortps_agent   ]\t @(topic) publisher: " << info.current_count_change
			<< " is not a valid value for SubscriptionMatchedStatus current count change.\033[0m" << std::endl;
	}

@[else]@
	n_matched = info.total_count;
@[end if]@
}

void @(topic)_Subscriber::SubListener::on_data_available(
	DataReader* reader)
{
	std::unique_lock<std::mutex> has_msg_lock(has_msg_mutex);
	if(has_msg.load() == true) // Check if msg has been fetched
	{
		has_msg_cv.wait(has_msg_lock); // Wait till msg has been fetched
	}
	has_msg_lock.unlock();

	if (reader->take_next_sample(&msg, &m_info) == ReturnCode_t::RETCODE_OK)
	{
		if (m_info.valid_data)
		{
			std::unique_lock<std::mutex> lk(*t_send_queue_mutex);

			++n_msg;
			has_msg = true;

			t_send_queue->push(topic_ID);
			lk.unlock();
			t_send_queue_cv->notify_one();

		}
	}
}

bool @(topic)_Subscriber::hasMsg()
{
	if (m_listener.n_matched > 0) {
		return m_listener.has_msg.load();
	}

	return false;
}

@(topic)_msg_t @(topic)_Subscriber::getMsg()
{
	return m_listener.msg;
}

void @(topic)_Subscriber::unlockMsg()
{
	if (m_listener.n_matched > 0) {
		std::unique_lock<std::mutex> has_msg_lock(m_listener.has_msg_mutex);
		m_listener.has_msg = false;
		has_msg_lock.unlock();
		m_listener.has_msg_cv.notify_one();
	}
}
