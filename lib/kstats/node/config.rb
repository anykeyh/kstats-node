module Kstats
  module Node
    module Config
      def self.init config_file
        @config ||= {}
        @config.merge!(config_file)
      end

      def self.[] key, default = nil
        path = key.to_s.split(/\./)

        explore_path(path) || default
      end

      private

      def self.explore_path path, current = nil, idx=0
        if idx == 0 && current.nil?
          current = @config
        end

        if current.nil?
          nil
        else
          if idx == path.count-1
            if current.instance_of?(Hash)
              current[path[idx]]
            else
              nil
            end
          else
            explore_path path, current[path[idx]], idx+1
          end
        end
      end
    end
  end
end
