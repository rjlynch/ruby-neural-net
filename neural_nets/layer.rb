module NeuralNets
  class Layer
    attr_reader :neurones

    def initialize(input_size:, output_size:)
      @neurones = Array.new(output_size) { Neurone.new(input_size) }
    end

    def y(activation_vector)
      @neurones.map { |neurone| neurone.y(activation_vector) }
    end

    def inspect
      "Layer #{@neurones.count} neurones"
    end
  end
end
