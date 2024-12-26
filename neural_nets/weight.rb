module NeuralNets
  class Weight
    attr_accessor :value, :input
    attr_reader :adjustments

    def initialize
      @value = rand(-1.0..1.0)
      @input = nil
      @adjustments = []
    end

    def update!(learning_rate)
      average_dw = @adjustments.sum / @adjustments.size
      @value -= average_dw * learning_rate
      @adjustments = []
    end

    def y(x)
      @input = x
      @input * @value
    end
  end
end
