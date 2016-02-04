=begin
# Puppet Module  : netdev_stdlib_nos
# File           : puppet/provider/nos_netdev_device/nos.rb
# Version        : 05-15-2015
# Description    : 
#
#   This file contains the NOS specific code to implement a 
#   netdev_device.  The netdev_device is auto required for 
#   all instantiations of netdev resources.
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
require 'puppet/util/brocade_util'

require 'uri'
require 'timeout'

Puppet::Type.type(:nos_netdev_device).provide(:nos) do
  
  @doc = "NOS Device Managed Resource for auto-require"
	attr_accessor :target, :vcs_id, :rbridge_id
  
  ##### ------------------------------------------------------------   
  ##### Device provider methods expected by Puppet
  ##### ------------------------------------------------------------  
  def initialize(value={})
    super(value)
    @property_flush = {}
    @file_path  = File.expand_path(File.join(File.dirname(__FILE__), '../..','util/constants.yaml'))
    @conf = YAML.load(File.read(@file_path))

  end


  def exists?  
    @url = URI.parse("#{resource[:target]}")
    @transport = BrocadeNetConf.new("#{resource[:target]}")

    false
  end

  def create
      Puppet.info("#{self.resource.type}: CREATE #{resource[:name]}")    
      notice("#{self.resource.type}: CREATE #{resource[:name]}")
      

#child_pid = fork do
    
    
      Puppet.debug("Puppet::Device::NOS: connecting to NOS device #{@url.host}, #{@url.user}, #{@url.password}, #{@url.port}.")
          
      config = @transport.vcs_rbridge_config({:vcs_id => "#{resource[:vcs_id]}", :rbridge_id => "#{resource[:rbridge_id]}" }, {:xmlns => 'urn:brocade.com:mgmt:brocade-vcs'} )
      #puts config
#end

#begin
   #Timeout.timeout(20) do
          #Process.wait
   #end
#rescue Timeout::Error
        #puts "TIMEOUT OCCURED "
#end   
#puts "EXITING CHILD PID is #{child_pid}"
          
      
  end

  def destroy
      Puppet.info("#{self.resource.type}: DESTROY #{resource[:name]}")
  end

end
