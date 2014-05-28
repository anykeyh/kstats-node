module Kstats
  module Node
    module Helper
      #Entry:
      # Data from probe with:
      #   0: Date of the pick
      #   1: Value of the pick
      # Output:
      #   An array with value of average of each points
      def self.generate_array data, start, period, nb_points
        out_array = Array.new nb_points

        for i in 0...nb_points
          out_array[i] = [0.0, 0.0] # value and coef.
        end

        data.each do |x|
          #Position of the data over the period:
          poz = (x[0] - start)/60 # In minutes
          poz = poz / period.to_f # In percent between [0..1]

          next if poz < 0.0 || poz > 1.0

          p1,p2,f = (poz * nb_points).floor, (poz*nb_points).ceil, (poz*nb_points).abs.modulo(1)

          if f>0.5
            output = out_array[p1]
          else
            output = out_array[p2]
          end

          unless output.nil?
            output[0] = (x[1] + output[1]*output[0]) / ( output[1] + 1)
            output[1] += 1
          end
        end

        out_array.map{ |x| x[0].round(3) }
      end
    end
  end
end
