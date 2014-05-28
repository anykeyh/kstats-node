Kstats::Node::Probe.register 'disk' do
  category 'Hardware'
  name 'Disk usage'

  type :curve

  _self = self
  instance_eval do
    def parsedf
      disks = `df`.split(/\n/).map do |x|
        x.split(/\s+/)
      end

      disks.reject!{|x| x[0] == 'udev' ||  x[0] == 'none' || x[0] == 'tmpfs' || x[0] == 'Filesystem' }
      disks.map!{|x| {name: x[0], space: 100*(x[2].to_f/x[1].to_f) }}
    end
  end

  parsedf.each do |infos|
    var = infos[:name]

    variable var do
      desc "Filling of `#{infos[:name]}`"
      color "#0000FF"
      probe do
        val = _self.parsedf.select{|x| x[:name] == var }.first[:space]

        puts val

        val
      end
    end
  end

end