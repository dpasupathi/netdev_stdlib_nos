=begin
* Puppet Module  : netdev_stdlib_nos
* File           : puppet/type/nos_netdev_lag.rb
* Version        : 05-15-2015
* Description    : 
*
*    This file contains the Type definition for the network
*    Link Aggregation Group (LAG).  
*
=end

Puppet::Type.newtype(:nos_netdev_lag) do
  @doc = "Network Device Link Aggregation Group"

  ensurable
  feature :activable, "The ability to activate/deactive configuration"  

  ##### -------------------------------------------------------------    
  ##### Parameters
  ##### -------------------------------------------------------------    
  
  newparam( :name, :namevar=>true ) do
    desc "LAG Name"
  end
  
  newproperty( :active, :required_features => :activable ) do
    desc "Config activation"
    defaultto( :true )
    newvalues( :true, :false )
  end   

  newproperty(:description) do
    desc "The LAG Description"
  end
  
  newproperty( :minimum_links ) do
    desc "Number of active links required for LAG to be 'up' (1-32)"
    defaultto( 1 )
    munge { |v| Integer( v ) }
  end

  newproperty( :admin ) do
    desc "Port-channel admin state [up*|down]"
    defaultto( :up )
    newvalues( :up, :down )
  end  

  newproperty( :links, :array_matching => :all ) do
    desc "Array of Physical Interfaces"
    
    munge { |v|  Array( v ) }
    
    # the order of the array elements is not important
    # so we need to do a sort-compare
    def insync?( is )
      is.sort == @should.sort.map(&:to_s)
    end
    
  end  
    
  newproperty( :lacp ) do
    desc "LACP [ passive | active | on ]"
    defaultto( :on )
    newvalues( :active, :passive, :on )    
  end

  newproperty( :type ) do
    desc "LACP type [ brocade | standard ]"
    defaultto( :standard )
    newvalues( :brocade, :standard )    
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
