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
require 'net/netconf'
require 'net/netconf/transport'
require 'net/netconf/rpc'

class Netconf::Transport  
  def trans_send_hello
    trans_send(Netconf::RPC::MSG_HELLO)
    trans_send(Netconf::RPC::MSG_END)
  end

  def rpc_exec( cmd_nx )
      raise Netconf::StateError unless @state == :NETCONF_OPEN         
      
      # add the mandatory message-id and namespace to the RPC
      
      rpc_nx = cmd_nx.parent.root
      rpc_nx.default_namespace = Netconf::NAMESPACE
      rpc_nx['message-id'] = @rpc_message_id.to_s
      @rpc_message_id += 1
      
      # send the XML command through the transport and 
      # receive the response; then covert it to a Nokogiri XML
      # object so we can process it.
      
      rsp_nx = Nokogiri::XML( send_and_receive( cmd_nx.to_xml ))
      
      # the following removes only the default namespace (xmlns)
      # definitions from the document.  This is an alternative
      # to using #remove_namespaces! which would remove everything
      # including vendor specific namespaces.  So this approach is a 
      # nice "compromise" ... just don't know what it does 
      # performance-wise on large datasets.

      rsp_nx.traverse{ |n| n.namespace = nil }
      
      # set the response context to the root node; <rpc-reply>
      
      rsp_nx = rsp_nx.root
            
      # check for rpc-error elements.  these could be
      # located anywhere in the structured response
      
      rpc_errs = rsp_nx.xpath('//self::rpc-error')
      if rpc_errs.count > 0
        
        # look for rpc-errors that have a severity == 'error'
        # in some cases the rpc-error is generated with
        # severity == 'warning'
        
        sev_err = rpc_errs.xpath('error-severity[. = "error"]')
        
        # if there are rpc-error with severity == 'error'
        # or if the caller wants to raise if severity == 'warning'
        # then generate the exception
        
        if(( sev_err.count > 0 ) || Netconf::raise_on_warning )
          exception = Netconf::RPC.get_exception( cmd_nx )       
          raise exception.new( self, cmd_nx, rsp_nx )
        end        
      end        
      
      # return the XML with context at toplevel element; i.e.
      # after the <rpc-reply> element
      # @@@/JLS: might this be <ok> ? isn't for Junos, but need to check
      # @@@/JLS: the generic case.
      
      #rsp_nx.first_element_child
      rsp_nx
      
  end
end
