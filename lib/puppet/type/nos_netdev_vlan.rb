=begin
* Puppet Module  : netdev_stdlib_nos
* File           : puppet/type/nos_netdev_vlan.rb
* Version        : 05-15-2015
* Description    : 
*
*    This file contains the Type definition for the network
*    device Vlan resource.  
*
=end

Puppet::Type.newtype(:nos_netdev_vlan) do
  @doc = "Network Device VLAN"

  ensurable
  feature :activable, "The ability to activate/deactive configuration"  
  feature :describable, "The ability to add a description"
  feature :no_mac_learning, "The ability disable MAC learning"

  ##### -------------------------------------------------------------
  ##### Parameters
  ##### -------------------------------------------------------------  
  
  newparam(:name, :namevar=>true) do
    desc "The VLAN name"
  end
  
  ##### -------------------------------------------------------------
  ##### Properties
  ##### -------------------------------------------------------------  
  
  newproperty(:active, :required_features => :activable) do
    desc "Config activation"
    defaultto(:true)
    newvalues(:true, :false)
  end
 

  newproperty( :description ) do
    desc "VLAN Description"
  end
 
  newproperty(:vlan_id) do
    desc "The VLAN ID"
  end
  
  newproperty(:no_mac_learning, :required_features => :no_mac_learning) do
    desc "Do not learn MAC addresses; used for 2-port VLANs"
    defaultto(:false)
    newvalues(:true, :false)
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
