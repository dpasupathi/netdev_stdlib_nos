require 'nokogiri'
require 'set'


def get_ifname(name)
      	ifname = name[3..name.length]
	ifname
end

def get_ifname_short(type, name)
	ifname = ""
	iftype = ""
	if type == "tengigabitethernet"
	   iftype = "te"
	elsif type == "gigabitethernet"
	   iftype = "gi"
	elsif type == "fortygigabitethernet"
	   iftype = "fo"
	elsif type == "hundredgigabitethernet"
	   iftype = "hu"
	else
	   iftype = ""
	end
   
	if iftype != ""
	   ifname = iftype + "-" + name	
	end
	ifname

end
# name = "te-1/0/1"
def get_iftype(name)
      	type = name[0..1]
	iftype = "" 

      if type == "te"
        iftype = "tengigabitethernet"
      elsif type == "fo"
        iftype = "fortygigabitethernet"
      elsif type == "gi"
        iftype = "onegigabitethernet"
      elsif type == "hu"
        iftype = "hundredgigabitethernet"
      else
        iftype = "unknown"
      end
	iftype
end

def get_if_xml(name, arg=nil)
	ifname = get_ifname(name)
	iftype = get_iftype(name)
        interface = Nokogiri::XML(@conf["INTERFACE"])

        ifNode = interface.at("interface") # fetch our element
        if_node = Nokogiri::XML::Node.new( iftype, ifNode )

        name = Nokogiri::XML::Node.new( 'name', if_node )
        name.content = ifname
	if_node << name

	if arg != nil
	        argNode = Nokogiri::XML::Node.new( arg, if_node )
		if_node << argNode
	end
        ifNode <<  if_node
	#puts ifNode
	ifNode

end

def get_if_swport_xml(name, nodetype=nil)
	iftype = get_iftype(name)
	ifNode = get_if_xml(name)

	iftype_node = ifNode.at(iftype) # fetch our element
	swport_str = Nokogiri::XML(@conf["SWITCH_PORT_BASIC"])
	swport = swport_str.at('switchport-basic')
	iftype_node.add_child(swport.to_xml)

	if nodetype != nil
		iftype_node = ifNode.at(iftype) # fetch our element
		type_str = "SWITCH_PORT_"+nodetype
		#puts type_str
		swport_str = Nokogiri::XML(@conf["#{type_str}"])
		#puts swport_str
		swport = swport_str.at('switchport')
		iftype_node.add_child(swport.to_xml)

	end
	ifNode

end


def vlans_toset(vlans)
	ret = Set.new
	if vlans != nil && !vlans.empty?
					#puts vlans.class
	#if val_str != ""
	#val_str.split(',').each do |val|
	if String == vlans.class
					vlan_arr = vlans.split(',')
	elsif Array == vlans.class
					vlan_arr = vlans
	else
					return ret
	end
		vlan_arr.each do |val|
			val =  val.strip
			rng=val.split('-').inject { |s,e| s.to_i..e.to_i }		
			if (Range == rng.class)
				rng_arr = rng.to_a
				ret.merge(rng_arr)
			elsif
				ret.add(rng)
			end
		end
	end
	ret
end

def list_tostring (s)
# Iterate the collection.
	ret = ""
	s.each do |n|
		# Display the element.
		ret = ret+", "+n.to_s
	end
	ret[2..ret.length]
end

