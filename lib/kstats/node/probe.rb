module Kstats
  module Node
    class Probe

      class << self
        attr_accessor :registered

        def register name, &block
          @registered << Probe.new(name).from_dsl(&block)
        end

        def get_format probe
          probe = @fixed_registered.select{|x| x.id == probe }.first
          if probe.nil?
            return nil
          else
            {
              type: probe.type,
              variables: probe.variables.inject({}){ |h, x|
                h[x.name] = {}
                h[x.name][:desc] = x.desc
                h[x.name][:color] = x.color
                h
              }
            }
          end
        end

        def reload_and_test!
          @fixed_registered = @registered
          @registered = []

          dir = Kstats::Node::Config['probes_dir']

          Dir[File.join(dir, "*.rb")].each do |probe_file|
            begin
              load(probe_file)
            rescue => e
              puts "Unable to load #{probe_file}: #{e}"
              puts "*\t#{e.backtrace.join("\n*\t")}"
            end
          end

          probes = {}

            @registered.each do |probe|
              begin
                probes[probe.id] = probe.test
              rescue => e
                puts "Exception for probe #{probe.id} : #{e.message}"
                puts "*\t#{e.backtrace.join("\n*\t")}"
              end
            end

          @fixed_registered  = @registered

          probes
        end

        def list
          probe_categories = {}
          @fixed_registered.each do |probe|
            probe_categories[probe.category] ||= []
            probe_categories[probe.category] << { name: probe.name, id: probe.id }
          end

          probe_categories
        end
      end

      class Variable
        attr_reader :name
        attr_accessor :desc, :color, :probe

        def initialize name, parent
          @name = name
          @parent = parent
        end

        def command
          @parent.command
        end

        def test
          instance_eval(&probe)
        end

        def from_dsl &block
          dsl = DSL.new(self)
          dsl.instance_eval(&block)

          return self
        end

        class DSL
          def initialize variable
            @variable = variable
          end

          def desc val
            @variable.desc = val
          end

          def color val
            @variable.color = val
          end

          def probe &val
            @variable.probe = val
          end
        end
      end

      attr_reader :id
      attr_accessor :variables, :category, :name, :type, :command, :command_block

      def initialize id
        @variables = []
        @id = id
      end

      def from_dsl &block
        DSL.new(self).instance_eval(&block)

        return self
      end

      def add_variable var
        @variables << var
      end

      def test
        @command = self.command_block.call unless self.command_block.nil?

        @variables.inject({}){|h, x| h[x.name] = x.test; h }
      end

      class DSL
        def initialize probe
          @probe = probe
        end

        def category val
          @probe.category = val
        end

        def name val
          @probe.name = val
        end

        def command &block
          @probe.command_block = block
        end

        def type val
          @probe.type = val
        end

        def variable name, &block
          @probe.add_variable Variable.new(name, @probe).from_dsl(&block)
        end
      end
    end
  end
end