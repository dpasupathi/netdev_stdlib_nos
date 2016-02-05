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
module NetdevBrocade
  module Log
    class << self   
      def err( msg, args = {} )
        Puppet::Util::Log.create({:source => :BROCADE, 
          :level => :err, 
          :message => msg }.merge( args ))        
      end      
      def notice( msg, args = {} )
        Puppet::Util::Log.create({:source => :BROCADE, 
          :level => :notice, 
          :message => msg }.merge( args ))        
      end      
      def info( msg, args = {} )
        Puppet::Util::Log.create({:source => :BROCADE, 
          :level => :info, 
          :message => msg }.merge( args ))        
      end
      def debug( msg, args = {} )
        Puppet::Util::Log.create({:source => :BROCADE, 
          :level => :debug, 
          :message => msg }.merge( args ))        
      end      
    end
  end
end
