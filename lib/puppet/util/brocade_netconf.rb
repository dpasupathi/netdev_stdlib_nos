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
require 'uri'
require 'timeout'
require 'puppet/util/patch_netconf'
require 'puppet/util/brocade_util'


class BrocadeNetConf
	def initialize( target )
		@url = URI.parse(target)
		@login = { :target => "#{@url.hostname}", :port => "#{@url.port}", :username => "#{@url.user}", :password => "#{@url.password}" }
		Puppet.debug(@login)
		#timeout seconds
		@timeout = 20;
    @file_path  = File.expand_path(File.join(File.dirname(__FILE__), '/','constants.yaml'))
    @conf = YAML.load(File.read(@file_path))

	end

	def vcs_rbridge_config(vcs_node, xp)
		config = ""

		timeout(@timeout) do
			begin
				Netconf::SSH.new( @login ){ |dev|
					config = dev.rpc.vcs_rbridge_config(vcs_node, xp)
				}
				rescue Exception => open_error
					if ("SocketError" == open_error.class) 
    				puts "Unable to Login to switch "+@login.to_s + " Error: #{open_error}"
						raise RuntimeError, "Unable to Login to switch "+@login.to_s + " Error: #{open_error}"
					elsif
    				#puts "Time out after sec"
  						raise RuntimeError, "Time out Error"
					end
			end

		end


		return config
	end

	def get_config (xml_node)
		config =""
		#puts  __method__
		#puts  "Started At #{Time.now}"
		timeout(@timeout) do
				config =  get_config_sync (xml_node)
		end
		rescue Timeout::Error => e
    				#puts "Time out after sec"
  		raise RuntimeError, "Time out Error"
		#puts  "End At #{Time.now}"
		#puts "After "+val

		return config
	end


	def get_config_sync (xml_node)
		#puts  __method__
		Puppet.debug(__method__)
		Puppet.debug(xml_node.to_xml)

		config =""
		#puts  "Started At #{Time.now}"
			begin
				Netconf::SSH.new( @login ){ |dev|
					begin
  					config = dev.rpc.get_config(xml_node)
        	rescue Netconf::RpcError => e
	# print error-message
						element =  e.rsp
						emessage = element.at("error-message")
						element.xpath('//error-message').each do |node|
								msg =  node.content
    						raise RuntimeError, "#{msg}"
							#puts msg
						end
      ensure
				Puppet.debug(config)

					end
						}
				rescue 
								raise
				end

			#puts  "End At #{Time.now}"
			return config

	end

	def set_config (xml_node)
		#puts  __method__
		config =""
		#puts  "Started At #{Time.now}"
		timeout(@timeout) do
				config =  set_config_sync (xml_node)
		end
		rescue Timeout::Error => err
    				#puts "Time out after sec"
  		raise RuntimeError, "Time out Error"

		return config
	end

	def set_config_sync (xml_node)
		#puts  __method__
  Puppet.debug(__method__)
	Puppet.debug(xml_node.to_xml)

   		var = "set_config - "  + xml_node.to_xml
		config = ""
		Netconf::SSH.new( @login ){ |dev|
			begin
    				config = dev.rpc.edit_config("running",xml_node)
        rescue Netconf::RpcError => e
	# print error-message
				element =  e.rsp
				emessage = element.at("error-message")
				element.xpath('//error-message').each do |node|
				msg =  node.content
    				raise RuntimeError, "#{msg}"
				end
  ensure
		Puppet.debug(config)

			end
			}
		return config
	end

	def get_sw_if_vlan( name , xpath)
		ret = ''
		ifNode = get_if_xml(name)
		config = get_config(ifNode)
		#puts config
		#puts "xpath is #{xpath}"
		config.xpath("#{xpath}").each do |node|
			ret = node.content
		end
		ret
	end

	def get_port_channel_detail()
		config = ""
		#puts "Started At #{Time.now}"
    #puts "Started At #{Time.now}"

		timeout(@timeout) do
			begin
						Netconf::SSH.new( @login ){ |dev|
							config = dev.rpc.get_port_channel_detail({}, {:xmlns => 'urn:brocade.com:mgmt:brocade-lag'} )
						}
				rescue Exception => open_error
					if ("SocketError" == open_error.class) 
    				puts "Unable to Login to switch "+@login.to_s + " Error: #{open_error}"
						raise RuntimeError, "Unable to Login to switch "+@login.to_s + " Error: #{open_error}"
					elsif
    				#puts "Time out after sec"
  						raise RuntimeError, "Time out Error"
					end
			end

		end


		return config
	end


	def dev_lag_links(po_id)
		has_array = []
    config = get_port_channel_detail

		lacp_child_nodes = ""
		config.xpath('//lacp').each do |lacp_node|
			poid_node = lacp_node.first_element_child
			poid_node_content = poid_node.content
			if poid_node_content == po_id
			   lacp_child_nodes = lacp_node.children
			   break
			end
		end

		if lacp_child_nodes != ""

			lacp_child_nodes.each do |top_elem|
				if top_elem.name == "aggr-member"
					link_type = ""
					link_name = ""
					top_elem.children.each do |attr|
					   if attr.name == "interface-type"
						link_type =  attr.content
					   end
					   if attr.name == "interface-name"
						link_name =  attr.content
					   end
					end
					if link_name != "" && link_type != ""
						ifname = get_ifname_short(link_type, link_name)
						if ifname != ""
							#create 2D array
							sub_array = []
							sub_array.push(ifname)
							has_array.push(sub_array)
						end
						#puts ifname
						link_name = ""
						link_type = ""
					end
				  
				end
			end
		end
		has_array
	end
	

end
