=begin
* Puppet Module  : netdev_stdlib_nos
* File           : puppet/type/nos_netdev_l2_interface.rb
* Version        : 05-15-2015
* Description    : 
*
*    This file contains the Type definition for the network
*    device layer-2 interface (i.e. switch port).  The
*    network device module separates the physical port
*    controls from the service function.  Physical port
*    controls are defined in nos_netdev_interface.rb
*
* License:
*
* Copyright 2016 Brocade Communications System, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*        http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations
* under the License.
*
* LICENSE (BSD-2)
* ===============
* Copyright (c) 2013, Juniper Networks
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without 
* modification, are permitted provided that the following conditions are met:
*
* Redistributions of source code must retain the above copyright notice, 
* this list of conditions and the following disclaimer.
*
* Redistributions in binary form must reproduce the above copyright notice, 
* this list of conditions and the following disclaimer in 
*  the documentation and/or other materials provided with the distribution.
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
=end

Puppet::Type.newtype(:nos_netdev_l2_interface) do
  
  @doc = "Ethernet layer2 (switch-port) interface"
  
  ensurable
  feature :activable, "The ability to activate/deactive configuration"
  
  ##### -------------------------------------------------------------
  ##### Parameters
  ##### -------------------------------------------------------------  
  
  newparam(:name, :namevar=>true) do
    desc "The switch interface name"
  end
  
  ##### -------------------------------------------------------------
  ##### Properties
  ##### -------------------------------------------------------------  
  
  newproperty(:active, :required_features => :activable ) do
    desc "Config activation"
    defaultto(:true)
    newvalues(:true, :false)
  end   
  
  newproperty(:vlan_tagging) do
    desc "The switch interface vlan-tagging mode"
#    defaultto(:enable)
    newvalues(:enable,:disable)     
  end

  newproperty(:description) do
    desc "The switch interface description."
  end
  
  newproperty(:tagged_vlans, :array_matching => :all) do
    desc "Array of VLAN names used for tagged packets"
    defaultto([])
    munge{ |v| Array(v) }
    
    def insync?(is)
      is.sort == @should.sort.map(&:to_s)
    end
    
    def should_to_s( value )
      "[" + value.join(',') + "]"
    end
    def is_to_s( value )
      "[" + value.join(',') + "]"
    end
    
  end
  
  newproperty(:untagged_vlan) do
    desc "VLAN used for untagged packets"
  end
  
  newproperty(:native_vlan) do
    desc "VLAN used for native packets"
  end

  newproperty( :target ) do
    desc "Device connection information, http:<ip>:<port><:username>:<password>"
  end
  
  ##### -------------------------------------------------------------
  ##### Auto require the netdev_device resource - 
  #####   There must be one netdev_device resource defined in the
  #####   catalog, it doesn't matter what the name of the device is,
  #####   just that one exists.  
  ##### ------------------------------------------------------------- 
  
  #autorequire(:nos_netdev_device) do    
    #netdev = catalog.resources.select{ |r| r.type == :nos_netdev_device }[0]
    #raise "No netdev_device found in catalog" unless netdev
    #netdev.title   # returns the name of the netdev_device resource
  #end   
    
  #autorequire(:nos_netdev_vlan) do    
    #vlans = self[:tagged_vlans] || []
    #vlans << self[:untagged_vlan] if self[:untagged_vlan]
    #vlans.flatten
  #end    
  
end
