require 'yogo/structure/base'

module YOGO
  module Structure
    class Mine < Base

      def self.name
        "Mine"
      end

      def self.description
        "+5 iron or coal"
      end

      def self.valid_tile?(tile)
        [ :coal, :iron ].include?(tile.resource)
      end

      def production
        { @tile.resource => 5 }
      end

      def causes
        { :air_pollution => 0.01 * @production,
          :water_pollution => 0.1 * @production
        }
      end

      def update(world)
        @running_cost = 10.0

        super
      end

    end
  end
end
