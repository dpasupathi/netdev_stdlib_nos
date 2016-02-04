=begin
# Puppet Module  : netdev_stdlib_nos
# File           : puppet/provider/nos_netdev_interface/nos.rb
# Version        : 05-15-2015
# Description    : 
#
#   This file contains the NOS specific code to implement a 
#   netdev_interface.  The netdev_interface resource allows 
#   management of physical Ethernet interfaces on NOS systems.
#
# Copyright 2016 Brocade Communications System, Inc.
# All rights reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#
=end
#require 'net/netconf'
require 'puppet/util/brocade_netconf'

require 'uri'
require 'yaml'

Puppet::Type.type(:nos_netdev_interface).provide(:nos) do
  @doc = "Manage NOS physical interfaces"
  

  def initialize(value={})
    super(value)
    @property_flush = {}
    @file_path  = File.expand_path(File.join(File.dirname(__FILE__), '../..','util/constants.yaml'))
    @url = URI.parse("#{resource[:target]}")
    @conf = YAML.load(File.read("#{@file_path}"))

  end
attr_accessor :admin_up, :admin, :description, :mtu, :speed, :duplex, :target  

  def exists?
    @url = URI.parse("#{resource[:target]}")
    @transport = BrocadeNetConf.new("#{resource[:target]}")
#puts "return false"
    false
  end
  
  def is_shut_present( iftype, ifname )
        ret = false;


	ifNode = get_if_xml("#{resource[:name]}", "shutdown")
        config = @transport.get_config(ifNode)

        node_admin_status = config.xpath('//shutdown')
        ret = node_admin_status.count > 0
        #puts "If Shut #{ifname} Exists: #{ret}"

        ret

  end

  def is_desc_present( iftype, ifname )

	ifNode = get_if_xml("#{resource[:name]}", "description")
        config = @transport.get_config(ifNode)
        ret = false;
        #config = @transport.get_config(get_config_request)
        node_status = config.xpath('//description')
        ret = node_status.count > 0
        #puts "If Desc #{ifname} Exists: #{ret}"

        ret

  end

  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    notice("#{self.resource.type}: CREATE #{resource[:name]}")

	Puppet.debug("Puppet::Device::NOS: connecting to NOS device #{@url.host}, #{@url.user}, #{@url.password}, #{@url.port}.")
          
      mtu = "#{resource[:mtu]}"
      desc = "#{resource[:description]}"
      speed = "#{resource[:speed]}"
      name = "#{resource[:name]}"
      ifname = get_ifname(name)
      iftype = get_iftype(name)
      ifNode = get_if_xml(name)
     
      swport = get_if_swport_xml(name)
      admin = "#{resource[:admin]}"
     

        iftype_node = ifNode.at(iftype) # fetch our element

	desc_present = is_desc_present(iftype, ifname)
if !desc.empty?
        desc_node = Nokogiri::XML::Node.new( 'description', iftype_node )
        desc_node.content = desc
      if desc == "null"
      	if desc_present == true
                desc_node['operation'] = "delete"
	end
      end

        iftype_node <<  desc_node
end

if !mtu.empty?
        mtu_node = Nokogiri::XML::Node.new( 'mtu', iftype_node )
        mtu_node.content = mtu
        iftype_node <<  mtu_node
end

if !speed.empty?
        speed_node = Nokogiri::XML::Node.new( 'speed', iftype_node )
        speed_node.content = speed
        iftype_node <<  speed_node
end
if !admin.empty?
# check if admin state changed ?
	shut_present = is_shut_present(iftype, ifname)
	send_rpc = false
	if (shut_present && admin == "up")
	  send_rpc = true
        elsif (shut_present != true && admin == "down")
	  send_rpc = true
        end
	if send_rpc
 		shut_node = Nokogiri::XML::Node.new( 'shutdown', iftype_node )
      		if admin == "up"
          		shut_node['operation'] = "delete"
      		end
        	iftype_node <<  shut_node
	end
end



        config = @transport.set_config(ifNode)

        
 end
 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
  end

end
