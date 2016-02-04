=begin
# Puppet Module  : netdev_stdlib_nos
# File           : puppet/provider/nos_netdev_vlan/nos.rb
# Version        : 05-15-2015
# Description    : 
#
#   This file contains the NOS specific code to implement a 
#   netdev_vlan resource.  The netdev_vlan resource allows 
#   for the management of the VLAN database in NOS.
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

Puppet::Type.type(:nos_netdev_vlan).provide(:nos) do
  @doc = "Manage NOS VLAN database"
  
  attr_accessor :vlan_id, :name, :target, :description

  def initialize(value={})
    super(value)
    @property_flush = {}
    @file_path  = File.expand_path(File.join(File.dirname(__FILE__), '../..','util/constants.yaml'))
    @conf = YAML.load(File.read("#{@file_path}"))
  end

  def get_desc_present( vlan )
        builder = Nokogiri::XML(@conf['CREATE_VLAN_INTERFACE'])
        element = builder.at('name') # fetch our element
        element.content = vlan

        ret = "";
	config = @transport.get_config(builder)
        node_status = config.xpath('//description')
        present = node_status.count > 0
        if present
           ret = node_status.first.content
        end
        ret

  end


  def exists?
    @transport = BrocadeNetConf.new("#{resource[:target]}")
        vlan = "#{resource[:vlan_id]}"
        desc = "#{resource[:description]}"
        ens = "#{resource[:ensure]}"

        builder = Nokogiri::XML(@conf['CREATE_VLAN_INTERFACE'])
        element = builder.at('name') # fetch our element
        element.content = vlan
 	ret = false;
	config = @transport.get_config(builder)
	val =  config.xpath('//interface')  
	ret = val.count >0

       # if vlan is present check if desc is modified ?
	if ens != "absent"
        if ret
                if !desc.empty?
                        old_desc = get_desc_present(vlan)
                        ret = (desc==old_desc)
                end
        end
	end
        ret

  end
  
  def create
        vlan = "#{resource[:vlan_id]}"
        desc = "#{resource[:description]}"

        rpc = Nokogiri::XML(@conf['CREATE_VLAN_INTERFACE'])
        element = rpc.at('name') # fetch our element
        element.content = vlan

        vlan_node = rpc.at('vlan') # fetch our element

        desc_present = get_desc_present(vlan)
       present = desc_present.empty?

	if !desc.empty?
        	desc_node = Nokogiri::XML::Node.new( 'description', vlan_node )
        	desc_node.content = desc
      		if desc == "null"
        		if !desc_present.empty?
                		desc_node['operation'] = "delete"
        			vlan_node <<  desc_node
        		end
		elsif
			vlan_node <<  desc_node

      		end
	end


	config = @transport.set_config(rpc)

  end
 
  def destroy
      #Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
      puts("#{self.resource.type}: DESTROY #{resource[:name]}")

        vlan = "#{resource[:vlan_id]}"
	
        rpc = Nokogiri::XML(@conf['DELETE_VLAN_INTERFACE'])
        element = rpc.at('name') # fetch our element
        element.content = vlan

	config = @transport.set_config(rpc)


  end
 
  
end
