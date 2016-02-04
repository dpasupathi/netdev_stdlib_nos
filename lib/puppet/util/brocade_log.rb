
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
