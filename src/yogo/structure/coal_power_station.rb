require 'yogo/structure/base'

module YOGO
  module Structure
    class CoalPowerStation < Base

      def self.name
        "Coal Power Station"
      end

      def self.description
        "2 coal -> 10 power"
      end

      def self.valid_tile?(tile)
        tile.terrain != :water
      end

      def self.setup_cost
        17
      end

      def self.running_cost
        1.0
      end

      def self.produces
        { :power => 10 }
      end

      def production
        { :power => 10 * @production }
      end

      def consumes
        { :coal => 2 }
      end

      def causes
        { :air_pollution => 0.15 * @production,
          :water_pollution => 0.005 * @production
        }
      end

      # TODO: Extract to a Concern along with Foundry
      def do_production(world)
        cs = self.consumes
        cs.each do |commodity, quantity|
          item = owner.consume(commodity, quantity, world)
          @production = (item[:fulfilled].to_f / quantity.to_f).floor.to_i
          @running_cost += item[:price]
        end
      end

    end
  end
end
