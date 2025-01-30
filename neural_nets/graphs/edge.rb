module Graphs
  class Edge
    attr_reader :left, :right, :nodes
    attr_accessor :value

    def initialize(left:, right:, value:)
      @left = left
      @right = right
      @value = value.to_f
      @nodes = [@left, @right]
    end

    def as_json
      {
        left: left.as_json,
        right: right.as_json,
        value: value
      }
    end
  end
end
