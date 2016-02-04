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
