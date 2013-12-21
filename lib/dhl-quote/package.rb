module Shipping
  class Package
    attr_reader :piece_id, :height, :depth, :width, :weight

    def initialize(options={})
      @piece_id = options[:piece_id]
      @height = options[:height]
      @depth = options[:depth]
      @width = options[:width]
      @weight = options[:weight]
    end
  end
end
