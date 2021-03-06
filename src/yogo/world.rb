require 'yogo/map'
require 'yogo/market'
require 'yogo/structure/all'
require 'yogo/entity/player'
# require 'yogo/entity/corporation'

module YOGO
  class World
    attr_reader :player
    attr_accessor :ui_handler, :game

    attr_reader :map, :market
    attr_reader :population
    attr_reader :month, :year

    def initialize
      @map = Map.new(40,40)
      @market = Market.new

      @player = Entity::Player.new
      @map.entities << @player

      @year = 2030
      @month = 1

      @turn = 0
    end

    def generating?
      @map.unmapped > 0 || !@map.opponents_generated?
    end

    def update(game, container)
      if generating? then
        @map.world_gen_update(self)
        if !generating? then
          @game.running = true
        end
      end
    end

    def turn!
      @turn += 1

      @month += 1
      if @month == 13 then
        @month = 1
        @year += 1
      end

      @ui_handler.turn!
      puts "---------"
      puts "Turn: #{@turn}"
      @market.update(self)
      @map.update(self)

      puts @market.live_demand.inspect

      @air_pollution = 0.0
      @water_pollution = 0.0
      @population = 0.0

      @map.entities.each do |entity|
        # TODO: You win if you are the only non-country left in the game
        if entity.is_a?(Entity::Country)
          @air_pollution += entity.statistics[:air_pollution]
          @water_pollution += entity.statistics[:water_pollution]
          @population += entity.population
        end
      end

      puts "WORLD: AIR: #{@air_pollution} WATER: #{@water_pollution} RATE: #{warming_rate}"
      if warming_rate > 0.75 then
        @ui_handler.notice("Scientists report the polar icecaps are melting rapidly")
      elsif warming_rate > 0.5 then
        @ui_handler.notice("Scientists report the polar icecaps are melting")
      elsif warming_rate > 0.25 then
        @ui_handler.notice("Scientists report the climate is starting to change heavily")
      elsif warming_rate > 0.05 then
        @ui_handler.notice("Scientists are concerned about climate change")
      elsif warming_rate < 0.00 then
        @ui_handler.notice("Scientists are pleased that climate change appears to be reversing")
      end

      if @population <= 0.01 then
        @ui_handler.game_over!("You are the last one alive. Everyone else is dead")
      elsif @population <= 1.00 then
        @ui_handler.critical("Less than 1 million people remain alive")
      elsif @population <= 10.00 then
        @ui_handler.critical("The global population has been decimated to under 10 million people")
      end

      opponents = @map.entities.find_all { |x| x.is_a?(Entity::Corporation) && x.running? }
      if opponents.count <= 0 then
        @ui_handler.winner!("All your competitors are out of business. You are a global monopoly!")
      end
    end

    def warming_rate
      if @air_pollution.nil? then
        0.0
      else
        -0.5 + (@air_pollution / ((@map.width * @map.height) / 750.0))
      end
    end
  end
end
