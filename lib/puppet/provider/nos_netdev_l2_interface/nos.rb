=begin
# Puppet Module  : netdev_stdlib_nos
# File           : puppet/provider/nos_netdev_l2_interface/nos.rb
# Version        : 05-15-2015
# Description    : 
#
#   This file contains the NOS specific code to implement a 
#   netdev_l2_interface.   This module will manage NOS switchport
#   interfaces for providing layer 2 services.
#
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
require 'puppet/util/brocade_netconf'
require 'puppet/util/brocade_util'

require 'uri'
require 'yaml'

Puppet::Type.type(:nos_netdev_l2_interface).provide(:nos) do
  @doc = "Manage NOS switchport interfaces"
  
  attr_accessor :vlan, :vlan_tagging, :description, :tagged_vlans, :untagged_vlan, :native_vlan,  :target

  def initialize(value={})
    super(value)
    @property_flush = {}
    @file_path  = File.expand_path(File.join(File.dirname(__FILE__), '../..','util/constants.yaml'))
    @conf = YAML.load(File.read(@file_path))
  end
  
  def no_switchport
    #puts "no switch port "
      name = "#{resource[:name]}"
      ifname = get_ifname(name)
      iftype = get_iftype(name)

      ifSwitchport = get_if_swport_xml(name)
      element = ifSwitchport.at('name') # fetch our element
      element.content = ifname
      swport = ifSwitchport.at('switchport-basic') # fetch our element
      swport['operation'] = "delete"
      config = @transport.set_config(ifSwitchport)

  end

  def exists?
    @url = URI.parse("#{resource[:target]}")
    @transport = BrocadeNetConf.new("#{resource[:target]}")
# check if the switch port is on.
  en = "#{resource[:ensure]}"

	ret = ( en == "absent")
    ret
  end
 

	def handle_vlan_tagging
		vlan_tagging = "#{resource[:vlan_tagging]}"
    name = "#{resource[:name]}"
    ifname = get_ifname(name)
    ifSwitchport = get_if_swport_xml(name)
    ifSwitchportTrunk = get_if_swport_xml(name, "TRUNK")

		if vlan_tagging == "disable"
			no_switchport
			element = ifSwitchport.at('name') # fetch our element
			element.content = ifname
			config = @transport.set_config(ifSwitchport)
		elsif vlan_tagging == "enable"
# configure trunk mode
			element = ifSwitchportTrunk.at('name') # fetch our element
			element.content = ifname
#puts ifSwitchportTrunk
			config = @transport.set_config(ifSwitchportTrunk)
		else
			element = ifSwitchport.at('name') # fetch our element
			element.content = ifname
			config = @transport.set_config(ifSwitchport)
		end
	end


	def handle_vlans (name, vlans, xpath_type, port_node)
		#puts __method__
    ifname = get_ifname(name)

		# get the if from switch to compare
		xpath = ".//"+xpath_type
		sw_nvlan = @transport.get_sw_if_vlan(name, xpath)
		old_set = vlans_toset(sw_nvlan)
		new_set = vlans_toset(vlans)

		del_set = old_set - new_set
		del_node = port_node.dup
		del_set.each do |vlan|
			element = del_node.at('name') # fetch our element
			element.content = ifname
			element = del_node.at(xpath_type) # fetch our element
			if ("vlan" == xpath_type)
				node = Nokogiri::XML::Node.new( 'remove', element )
				node.content = vlan
				element <<  node
			else
				element['operation'] = "delete"
				element.content = vlan
			end
			config = @transport.set_config(del_node)
		end

		add_set = new_set - old_set
		add_node = port_node.dup
		add_set.each do |vlan|
			element = add_node.at('name') # fetch our element
			element.content = ifname
			element = add_node.at(xpath_type) # fetch our element
			if ("vlan" == xpath_type)
				node = Nokogiri::XML::Node.new( 'add', element )
				node.content = vlan
				element <<  node
			else
				element.content = vlan
			end

			config = @transport.set_config(add_node)
		end

	end

	def handle_native_vlans
    		port_node = get_if_swport_xml(name, "NATIVE_VLAN")
  		name = "#{resource[:name]}"
		vlans = "#{resource[:native_vlan]}"
		handle_vlans(name, vlans, "native-vlan-id",port_node )
	end

	def handle_untagged_vlans
    		port_node = get_if_swport_xml(name, "UNTAG_VLAN")
  		name = "#{resource[:name]}"
		vlans = "#{resource[:untagged_vlan]}"
		handle_vlans(name, vlans, "accessvlan",port_node )
	end

	def handle_tagged_vlans
    		port_node = get_if_swport_xml(name, "TAG_VLAN")
  		name = "#{resource[:name]}"
    		vlans = resource[:tagged_vlans].flatten
		handle_vlans(name, vlans, "vlan",port_node )
	end

  def create
  	Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
  	notice("#{self.resource.type}: CREATE #{resource[:name]}")
		handle_vlan_tagging
		handle_native_vlans
		handle_tagged_vlans
		handle_untagged_vlans
 end

 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    puts "Destroy called"
    no_switchport

  end


end
