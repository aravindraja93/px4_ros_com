@###############################################
@#
@# EmPy template for generating <msg>_uRTPS_UART.cpp file
@#
@###############################################
@# Start of Template
@#
@# Context:
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
 * @@file @(topic)_Publisher.h
 * This header file contains the declaration of the publisher functions.
 *
 * This file was adapted from the fastrtpsgen tool.
 */


#ifndef _@(topic)__PUBLISHER_H_
#define _@(topic)__PUBLISHER_H_

#include <fastdds/dds/domain/DomainParticipant.hpp>
#include <fastdds/dds/publisher/DataWriter.hpp>
#include <fastdds/dds/publisher/DataWriterListener.hpp>

@[if version.parse(fastrtps_version) <= version.parse('1.7.2')]@
#include "@(topic)_PubSubTypes.h"
@[else]@
#include "@(topic)PubSubTypes.h"
@[end if]@

using namespace eprosima::fastdds::dds;

@[if version.parse(fastrtps_version) <= version.parse('1.7.2')]@
@[    if ros2_distro]@
using @(topic)_msg_t = @(package)::msg::dds_::@(topic)_;
using @(topic)_msg_datatype = @(package)::msg::dds_::@(topic)_PubSubType;
@[    else]@
using @(topic)_msg_t = @(topic)_;
using @(topic)_msg_datatype = @(topic)_PubSubType;
@[    end if]@
@[else]@
@[    if ros2_distro]@
using @(topic)_msg_t = @(package)::msg::@(topic);
using @(topic)_msg_datatype = @(package)::msg::@(topic)PubSubType;
@[    else]@
using @(topic)_msg_t = @(topic);
using @(topic)_msg_datatype = @(topic)PubSubType;
@[    end if]@
@[end if]@

class @(topic)_Publisher
{
public:
	@(topic)_Publisher();
	virtual ~@(topic)_Publisher();
	bool init(const std::string &ns, const std::vector<std::string>& whitelist, std::string topic_name = "");
	void run();
	void publish(@(topic)_msg_t *st);
private:
	DomainParticipant *mp_participant;
	Publisher *mp_publisher;
	Topic *mp_topic;
	DataWriter *mp_writer;
	TypeSupport mp_type;

	class PubListener : public DataWriterListener
	{
	public:
		PubListener() : n_matched(0) {};
		~PubListener() {};
		void on_publication_matched(DataWriter*, const PublicationMatchedStatus& info);
		std::atomic_int n_matched;
	} m_listener;
};

#endif // _@(topic)__PUBLISHER_H_
