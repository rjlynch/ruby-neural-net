module Graphs
  class Node
    attr_reader :value, :layer, :neurone

    def initialize(value:, layer:, neurone:)
      @value = value
      @layer = layer
      @neurone = neurone
    end

    def as_json
      {
        value: value,
        layer: layer,
        neurone: neurone
      }
    end
  end
end
