module NeuralNets
  class Neurone
    attr_reader :weights, :bias, :z, :activation

    # Neurone has a weight for each neurone in the previous layer
    def initialize(number_of_connections_in)
      @weights = Array.new(number_of_connections_in) { Weight.new }
      @bias = Bias.new
      @z = nil
      @activation = nil
    end

    # activation_vector is the output of the previous layer
    def y(activation_vector)
      @z = activation_vector.map.with_index do |x, i|
        @weights[i].y(x)
      end.sum + @bias.value

      @activation = SIGMOID.(@z)
    end

    def learn!(learning_rate)
      @weights.each { |weight| weight.update!(learning_rate) }
      @bias.update!(learning_rate)
    end
  end
end
