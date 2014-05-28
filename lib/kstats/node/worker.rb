module Kstats
  module Node
    class Worker
      def self.launch!
        insert_month = 0
        insert_week = 0
        insert_year = 0

        thread = Thread.new do
          begin
            begin
              puts "***GATHERING INFORMATIONS #{`date`}."
              probes = Kstats::Node::Probe.reload_and_test!

              if insert_month == 0
                insert_month = 30
                Database.save_probes_data(probes, :monthly)
              end

              if insert_week == 0
                insert_week = 7
                Database.save_probes_data(probes, :weekly)
              end

              if insert_year == 0
                insert_year = 365
                Database.save_probes_data(probes, :yearly)
              end

              insert_month  -= 1
              insert_week   -= 1
              insert_year   -= 1

              Database.save_probes_data(probes, :tick)
            rescue Exception => e
              puts e.message
              puts e.backtrace
            end
            sleep(300)
          end while true
        end

      end
    end
  end
end
