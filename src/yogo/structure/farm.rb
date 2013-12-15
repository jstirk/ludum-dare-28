require 'yogo/structure/base'

module YOGO
  module Structure
    class Farm < Base

      def production
        { :food => 3 }
      end

      def causes
        c = { :air_pollution => -0.005 }
        if @tile.resource == :arable then
          # Arable land needs little fertilizer, so has a lower water
          # pollution impact
          c[:water_pollution] = 0.005
        else
          c[:water_pollution] = 0.012
        end
        c
      end

      def update(world)
        @running_cost = 1.0
        super

        # Trees, stuff like that to absorb the pollution
        @tile[:air_pollution] -= 0.005

      end

    end
  end
end
