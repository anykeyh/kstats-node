Kstats::Node::Probe.register 'hwmem' do
  category 'Hardware'
  name 'Memory usage'

  type :curve

  command do
    cmd = `cat /proc/meminfo`
    lines = cmd.split(/\n/)

    memtotal = lines.select{|x| x =~ /MemTotal/ }.first.gsub(/[^0-9]/, '').to_f
    active = lines.select{|x| x =~ /Active/ }.first.gsub(/[^0-9]/, '').to_f
    inactive = lines.select{|x| x =~ /Inactive/ }.first.gsub(/[^0-9]/, '').to_f
    memfree = lines.select{|x| x =~ /MemFree/ }.first.gsub(/[^0-9]/, '').to_f
    swaptotal = lines.select{|x| x =~ /SwapTotal/ }.first.gsub(/[^0-9]/, '').to_f
    swapfree = lines.select{|x| x =~ /SwapFree/ }.first.gsub(/[^0-9]/, '').to_f

    [memtotal, active, inactive, memfree, swaptotal, swapfree]
  end

  variable :mem_load do
    desc 'Memory load (%)'
    color '#0000FF'
    probe do
      1-(command[3]/command[0])
    end
  end

  variable :swap_load do
    desc 'Swap load (%)'
    color '#FF0000'

    probe do
      1-(command[5]/command[4])
    end
  end
end