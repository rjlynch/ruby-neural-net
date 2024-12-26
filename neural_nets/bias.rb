module NeuralNets
  class Bias
    attr_reader :value, :adjustments

    def initialize
      @value = rand(-1.0..1.0)
      @adjustments = []
    end

    def update!(learning_rate)
      average_db = @adjustments.sum / @adjustments.size
      @value -= average_db * learning_rate
      @adjustments = []
    end
  end
end
