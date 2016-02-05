=begin
* Puppet Module  : netdev_stdlib_nos
* File           : puppet/type/nos_netdev_device.rb
* Version        : 05-15-2015
* Description    : 
*
*    This file contains the Type definition for the network
*    device.  This type exists so that the network device
*    resource can auto-require and create a dependency.  If
*    the network device is not available for any reason, then
*    the network device resources should not be processed.
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
* the documentation and/or other materials provided with the distribution.
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
=end

Puppet::Type.newtype(:nos_netdev_device) do
  @doc = "Network device resource to support autorequire relationships"
  
  ensurable
  
  ##### -------------------------------------------------------------
  ##### Parameters
  ##### -------------------------------------------------------------  
  
  newparam(:name, :namevar=>true) do
    desc "The network device name can be any placeholder value"
  end  
   

  newproperty( :target ) do
    desc "Device connection information, http:<ip>:<port><:username>:<password>"
  end
  
  newproperty( :vcs_id ) do
    desc "Virtual Cluster Id"
    munge { |v| Integer( v ) }
  end
    
  newproperty( :rbridge_id ) do
    desc "Rbridge Id"
    munge { |v| Integer( v ) }
  end  
end
