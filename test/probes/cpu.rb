Kstats::Node::Probe.register 'cpu' do
  category 'Hardware'
  name 'CPU usage'

  type :curve

  command{ `cat /proc/loadavg`.split(/\s/).map(&:to_f) }

  variable :load_avg_1mn do
    desc 'Load average (1mn)'
    color '#0000FF'
    probe do
      command[0]
    end
  end

  variable :load_avg_5mn do
    desc 'Load average (5mn)'
    color '#00FF00'
    probe do
      command[1]
    end
  end

  variable :load_avg_15mn do
    desc 'Load average (15mn)'
    color '#FF0000'
    probe do
      command[2]
    end
  end
end