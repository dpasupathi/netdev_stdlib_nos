=begin
* Puppet Module  : netdev_stdlib_nos
* File           : puppet/type/nos_netdev_interface.rb
* Version        : 05-15-2015
* Description    : 
*
*    This file contains the Type definition for the network
*    device physical interface.  The network device module 
*    separates the physical port controls from the service 
*    function.  Service controls are defined in their
*    respective type files;
*
=end

Puppet::Type.newtype(:nos_netdev_interface) do
  @doc = "Network Device Physical Interface"

  ensurable
  feature :activable, "The ability to activate/deactive configuration"  

  ##### -------------------------------------------------------------    
  ##### Parameters
  ##### -------------------------------------------------------------    
  
  newparam( :name, :namevar=>true ) do
    desc "Interface Name"
  end

  ##### -------------------------------------------------------------
  ##### Properties
  ##### -------------------------------------------------------------  
  
  newproperty( :active, :required_features => :activable ) do
    desc "Config activation"
    defaultto(:true)
    newvalues(:true, :false)
  end   
  
  newproperty( :admin ) do
    desc "Interface admin state [up*|down]"
    #defaultto( :up )
    newvalues( :up, :down )
  end  
  
  newproperty( :description ) do
    desc "Interface physical port description"
  end
  
  newproperty( :mtu ) do
    desc "Maximum Transmission Unit"
    munge { |v| Integer( v ) }
  end
  
  newproperty( :speed ) do
    desc "Link speed [auto*|10m|100m|1g|10g]"
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
  
end
