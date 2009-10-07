module PrependEngineRoutes
  module Configuration
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        attr_accessor :prepended_route_configuration_files
      end
    end
    
    module InstanceMethods
      def prepended_route_configuration_files
        @prepended_route_configuration_files || []
      end

      def add_prepended_route_configuration_file(file)
        @prepended_route_configuration_files ||= []
        @prepended_route_configuration_files << file
      end
    end
  end

  module Initializer
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :initialize_routing, :prepend_engine
      end
    end
    
    module InstanceMethods
      def initialize_routing_with_prepend_engine
        if configuration.prepended_route_configuration_files.present?
          configuration.prepended_route_configuration_files.each do |prepended_route_config|
            ActionController::Routing::Routes.add_configuration_file(prepended_route_config)
          end
        end
        initialize_routing_without_prepend_engine
      end
    end      
  end
end

Rails::Configuration.send :include, PrependEngineRoutes::Configuration
Rails::Initializer.send :include, PrependEngineRoutes::Initializer

