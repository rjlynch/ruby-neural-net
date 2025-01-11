module NeuralNets
  class NeuralNet
    include Persistence
    attr_reader :layers

    # First element of sizes is the input layer which doesn't have any weights or
    # biases so doesn't require a `Layer` instance.
    def initialize(sizes)
      raise ArgumentError, "at least 3 layers required" unless sizes.size >= 3

      @layers = sizes.each_cons(2).map do |input_size, output_size|
        Layer.new(input_size: input_size, output_size: output_size)
      end
    end

    def predict(x)
      prediction(feed_forward(x))
    end

    def train(x:, y:)
      activation = feed_forward(x)
      back_propagate(y)
      prediction(activation)
    end

    def learn!(learning_rate)
      @layers.each do |layer|
        layer.neurones.each do |neurone|
          neurone.learn!(learning_rate)
        end
      end
    end

    private

    def prediction(activation)
      activation.index(activation.max)
    end

    def output_layer
      @layers.last
    end

    def hidden_layers
      @layers[0..-2]
    end

    def feed_forward(activation_vector)
      @layers.each do |layer|
        activation_vector = layer.y(activation_vector)
      end

      activation_vector
    end

    def back_propagate(target)
      # How the cost chages WRT the activation of the first hidden layer
      # we'll build this up while passing through the output layer.
      dc_dasₗ₋₁ = []

      output_layer.neurones.each_with_index do |neurone, i|
        # This neurone's output
        ai = neurone.activation

        # What this neurone's output should be
        yi = target[i]

        # How the cost function changes WRT the activation of this neurone
        # Cost function is mean squared error (ai - yi)²
        dc_da = 2.0 * (ai - yi)

        # How the activation changes WRT the pre activation output of the
        # neurone (z)
        da_dz = SIGMOID_DERIVATIVE.(neurone.z)

        # How the pre activation output of the neurone changes WRT the bias
        dz_db = 1

        # How the cost changes WRT a change in this neurone's bias
        dc_db = dz_db * da_dz * dc_da

        # Accumulate the bias adjustments, so we can average them after a batch
        neurone.bias.adjustments << dc_db

        neurone.weights.each_with_index do |weight, j|
          # How the pre activation output changes WRT the weight
          # z = w * a₋₁ + b, where aₗ₋₁ is the output of the previous layer,
          # which is the input to this weight
          dz_dw = weight.input

          # How the cost changes WRT a change in weight
          dc_dw = dz_dw * da_dz * dc_da

          # Accumulate the weight adjustments, so we can average them after a
          # batch
          weight.adjustments << dc_dw

          # How the pre activation output of the neurone changes WRT the
          # input to the neurone (which is activation of the previous layer)
          # z = w * a₋₁ + b
          dz_daₗ₋₁ = weight.value

          # Accumulate how the cost function changes WRT the activation of the
          # previous layer, as we'll need it to calculate the dc_dw for the
          # previous layer (the first hidden layer).
          # Each weight of a neurone in the output layer maps to a neurone in
          # the previous layer, so we need to accumulate dc_da for each weight
          # of each neurone. I.E the jth weight of each neurone in this layer
          # maps to the ith neurone in the previous layer. So the output of a
          # hidden layer effects the cost through multiple paths.
          dc_dasₗ₋₁[j] = dc_dasₗ₋₁[j].to_f + (dz_daₗ₋₁ * dc_da * da_dz)
        end
      end

      hidden_layers.reverse.each_with_index do |layer, l|
        # copy the dc_daₗ₋₁ vector to use in this layer so we can build dc_daₗ₋₂
        # for the previous layer
        dc_dasₗ = dc_dasₗ₋₁

        # How the cost changes WRT the activation of the previous layer
        # we'll build this up while passing through the this layer.
        dc_dasₗ₋₁ = []

        layer.neurones.each_with_index do |neurone, i|
          # How the cost changes WRT the activation of this neurone.
          # Each neurone in this layer maps to a weight of each neurone in the
          # next layer, so dc_da for the ith neurone in this layer is set when we
          # itterate through the weights of the previous layer, it's the jth
          # weight of each neurone, ie  dc_daₗ[i] == Σ(dc_daₗ₋₁[j])
          # For the first hidden layer dc_daₗ[i] is set when we loop through
          # the neurones of the output layer (code above), for the subsequent
          # hidden layers it's set in the loop below.
          dc_da = dc_dasₗ[i]

          # How the activation changes WRT the pre activation output of the
          # neurone (z)
          da_dz = SIGMOID_DERIVATIVE.(neurone.z)

          # How the pre activation output of the neurone changes WRT the bias
          dz_db = 1

          # How the cost changes WRT a change in this neurone's bias
          dc_db = dz_db * da_dz * dc_da

          # Accumulate the bias adjustments, so we can average them after a batch
          neurone.bias.adjustments << dc_db

          neurone.weights.each_with_index do |weight, j|
            # How the pre activation output changes WRT the weight
            # z = w * a₋₁ + b, where aₗ₋₁ is the output of the previous layer,
            # which is the input to this weight
            dz_dw = weight.input

            # How the cost changes WRT a change in weight
            dc_dw = dz_dw * da_dz * dc_da

            # Accumulate the weight adjustments, so we can average them after a
            # batch
            weight.adjustments << dc_dw

            # How the pre activation output of the neurone changes WRT the
            # input to the neurone (which is activation of the previous layer)
            # z = w * a₋₁ + b
            dz_daₗ₋₁ = weight.value

            # Accumulate how the cost function changes WRT the activation of the
            # previous layer, as we'll need it to calculate the dc_dw for the
            # previous layer (the next layer in the loop)
            dc_dasₗ₋₁[j] = dc_dasₗ₋₁[j].to_f + (dz_daₗ₋₁ * dc_da * da_dz)
          end
        end
      end
    end
  end
end
