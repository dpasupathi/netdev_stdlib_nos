=begin
# Puppet Module  : netdev_stdlib_nos
# File           : puppet/provider/nos_netdev_lag/nos.rb
# Version        : 05-15-2015
# Description    : 
#
#   This file contains the NOS specific code to implement a 
#   netdev_lag.  This provider will allow you to manage and 
#   create LAG interfaces in NOS.
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
require 'uri'
require 'yaml'

Puppet::Type.type(:nos_netdev_lag).provide(:nos) do
  @doc = "Manage NOS Port-Channel interfaces"
  

  def initialize(value={})
    super(value)
    @property_hash = {}
    @node_hash = {}
    @poname = "#{resource[:name]}"
    @file_path  = File.expand_path(File.join(File.dirname(__FILE__), '../..','util/constants.yaml'))
    @url = URI.parse("#{resource[:target]}")
    @conf = YAML.load(File.read("#{@file_path}"))

  end

 attr_accessor :name, :description, :mtu, :speed, :lacp, :minimum_links, :links, :type, :target

  
  def exists?
    @transport = BrocadeNetConf.new("#{resource[:target]}")
	@has_links = []

	@po_name = "#{resource[:name]}"
	Puppet.debug("Puppet::Device::NOS: Po Exists check  #{resource[:name]}.")

        get_config_request = Nokogiri::XML(@conf['CONFIG_LAG'])

        name_node = get_config_request.at('name')
        name_node.content = @po_name

        po_node = get_config_request.at('port-channel')

	ret = false;
        config = @transport.get_config(get_config_request)

	val = config.xpath('//interface')
	ret = val.count > 0
 	
	if ret == true

        	shut_node = Nokogiri::XML::Node.new( 'shutdown', po_node )
        	po_node << shut_node

        	config = @transport.set_config(get_config_request)

	
        	config = @transport.get_config(get_config_request)
		node_admin_status = config.xpath('//shutdown')
		@netdev_admin = node_admin_status.count > 0

		@has_links =  @transport.dev_lag_links(@po_name)


		# Take first element and identify the type and mode
		if @has_links.empty? == false
			intf = @has_links[0][0]
			intf_type = get_iftype(intf)
			intf_name = get_ifname(intf)


			intf_config_request =  Nokogiri::XML(@conf['CONFIG_PHY_INTERFACE'])
			if_node = intf_config_request.at('interface')
			type_node = Nokogiri::XML::Node.new(intf_type, if_node)
			if_node << type_node

			ifname_node = Nokogiri::XML::Node.new('name', type_node)
			ifname_node.content = intf_name
			type_node << ifname_node

			cgroup_node = Nokogiri::XML::Node.new('channel-group', type_node)
			type_node << cgroup_node
        		intf_config = @transport.get_config(intf_config_request)

			ch_group = intf_config.xpath('//channel-group')
			ch_group.children.each do |leaf_element|
			   if leaf_element.name == "mode"
				@node_hash[:lacp] = leaf_element.content
			   elsif leaf_element.name == "type"
				@node_hash[:type] = leaf_element.content
			   end
		
			end
			
		end
	end

 	ret	
  end
 
  def create
    notice("#{self.resource.type}: CREATE #{resource[:name]}")
    
     Puppet.debug("Puppet::Device::NOS: connecting to NOS device #{@url.host}, #{@url.user}, #{@url.password}, #{@url.port}.")
          

	 rpc = Nokogiri::XML(@conf['CONFIG_LAG'])
	  
	 name_node = rpc.at('name')
	 name_node.content = @poname

	 po_node = rpc.at('port-channel')

        config = @transport.set_config(rpc)

	# minimum_link Configuration
	set_minimum_link

	# Description Configuration
	set_description

	#Admin status  configuration
	@shut_send_rpc = true
	set_admin

	#Add Members
	add_list = resource[:links]
	type = "#{resource[:type]}"
	mode = "#{resource[:lacp]}"
	set_links(add_list, type, mode)

      	@property_hash[:ensure] = :present
    
  end

  def del_links(del_list)
	
	iflist = del_list.flatten

	if iflist.empty? == false
         	iflist.each do |temp|
			interface = "#{temp}"
			iftype = get_iftype(interface)
			ifname = get_ifname(interface)

		 	if iftype != "unknown"
	 			channelgroup_rpc = Nokogiri::XML(@conf['CONFIG_PHY_INTERFACE'])
				if_node = channelgroup_rpc.at('interface')
				type_node = Nokogiri::XML::Node.new(iftype, if_node )
				if_node << type_node

				ifname_node = Nokogiri::XML::Node.new('name', type_node)
				ifname_node.content = ifname
				type_node << ifname_node

				cgroup_node = Nokogiri::XML::Node.new('channel-group', type_node)
				type_node << cgroup_node
				cgroup_node [ 'operation' ] = "delete"
				
        			config = @transport.set_config(channelgroup_rpc)
			end
				
		 end

	 end
  end


  def set_links(add_list, type, mode)

	iflist = add_list.flatten 

	if iflist.empty? == false
         	iflist.each do |temp|
			interface = "#{temp}"
			iftype = get_iftype(interface)
			ifname = get_ifname(interface)

		 	if iftype != "unknown"
	 			channelgroup_rpc = Nokogiri::XML(@conf['CONFIG_PHY_INTERFACE'])
				if_node = channelgroup_rpc.at('interface')
				type_node = Nokogiri::XML::Node.new(iftype, if_node )
				if_node << type_node

				ifname_node = Nokogiri::XML::Node.new('name', type_node)
				ifname_node.content = ifname
				type_node << ifname_node

				cgroup_node = Nokogiri::XML::Node.new('channel-group', type_node)
				type_node << cgroup_node
				
				po_node = Nokogiri::XML::Node.new('port-int', cgroup_node)
				po_node.content = @poname
				cgroup_node << po_node

				mode_node = Nokogiri::XML::Node.new('mode', cgroup_node)
				mode_node.content =  mode
				cgroup_node << mode_node

				lagtype_node = Nokogiri::XML::Node.new('type', cgroup_node)
				lagtype_node.content = type 
				cgroup_node << lagtype_node

        			config = @transport.set_config(channelgroup_rpc)
			end
				
		 end

	 end
	
  end


  def description
  end

  def description=(value)
	set_description

  end

  def admin
	
     if @netdev_admin == true && "#{resource[:admin]}" == "up"
	@shut_send_rpc = true
     end
     if @netdev_admin == false && "#{resource[:admin]}" == "down"
	@shut_send_rpc = true
     end

  end

  def admin=(value) 
	set_admin
  end

  def minimum_links
  end

  def minimum_links=(value)
  	set_minimum_link
  end

  def lacp
	has_mode = "#{@node_hash[:lacp]}"
	has_mode
  end

  def type
	has_type = "#{@node_hash[:type]}"
	has_type
  end

  def links
	@has_links 	
  end

  def lacp=(value)
  end

  def type=(value)
	
  end

  def links=(value)
	should = resource[:links] || []
	type = "#{@node_hash[:type]}"
	mode = "#{@node_hash[:lacp]}"


	#If manifest has empty string then remove all links

	if should.empty?
		del_links (@has_links)
		return
	end

	if @has_links.empty? == false 
		if @has_links == should
			del_links(@has_links)
			@has_links = []
		else

		    if mode != "#{resource[:lacp]}"
			raise RuntimeError,  "Mode mismatch between existing members and new members"
	   		return
		    end

		    if type != "#{resource[:type]}"
			raise RuntimeError,  "Type mismatch between existing members and new members"
	   		return
		   end
		end
	end
	

	has = @has_links
	should = should

	remove_links = has - should
	add_links  =  should - has
	type = "#{resource[:type]}"
	mode = "#{resource[:lacp]}"

	#First remove links
	del_links(remove_links)

	#Add links
	set_links(add_links, type, mode)
  end



  def set_description
      desc = "#{resource[:description]}"
    
	 desc_rpc = Nokogiri::XML(@conf['CONFIG_LAG'])
	 name_node = desc_rpc.at('name')
	 name_node.content = @poname
 	 po_node = desc_rpc.at('port-channel')

	 if desc.empty? == false
		description_node = Nokogiri::XML::Node.new( 'description', po_node )
		description_node.content = desc
		po_node << description_node
	 end
	 	
       config = @transport.set_config(desc_rpc)
  end

  def set_admin
	admin = "#{resource[:admin]}"
    
      Puppet.debug("Puppet::Device::NOS: connecting to NOS device #{@url.host}, #{@url.user}, #{@url.password}, #{@url.port}.")


      if @shut_send_rpc == true
      		shut_rpc = Nokogiri::XML(@conf['CONFIG_LAG'])
  
		name_node = shut_rpc.at('name')
		name_node.content = "#{@poname}"
		po_node = shut_rpc.at('port-channel')

		shut_node = Nokogiri::XML::Node.new( 'shutdown', po_node )
		if admin == "up"
			shut_node['operation'] = "delete"
			po_node << shut_node
		else 
			po_node << shut_node
		end

       		config = @transport.set_config(shut_rpc)
      end
  end
	

  def set_minimum_link
	min_link = "#{resource[:minimum_links]}"
    
      Puppet.debug("Puppet::Device::NOS: connecting to NOS device #{@url.host}, #{@url.user}, #{@url.password}, #{@url.port}.")
          
	 min_link_rpc = Nokogiri::XML(@conf['CONFIG_LAG'])
	 name_node = min_link_rpc.at('name')
	 name_node.content = @poname
 	 po_node = min_link_rpc.at('port-channel')
    	 
	 if resource[:minimum_links].between?(1,32)
	 	minlink_node = Nokogiri::XML::Node.new( 'minimum-links', po_node )
		minlink_node.content = resource[:minimum_links]
		po_node << minlink_node
	 else
		raise RuntimeError, "Invalid value for minimum_links"
 	 end
       config = @transport.set_config(min_link_rpc)
   end
 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
		rpc = Nokogiri::XML(@conf['CONFIG_LAG'])
	 
		name_node = rpc.at('name')
		name_node.content = @poname

		po_node = rpc.at('port-channel')
		po_node [ 'operation' ] = "delete"

       		config = @transport.set_config(rpc)
  end


end
