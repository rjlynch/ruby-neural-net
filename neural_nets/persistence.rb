module NeuralNets
  module Persistence
    module ClassMethods
      # Bit weird but we don't want to complicate the neural net code to
      # support loading
      def load(file_path = "./tmp/neural_net.json")
        json = File.read(file_path)
        data = JSON.parse(json)

        layers = data.map do |layer_data|
          neurones = layer_data.map do |neurone_data|
            weights = neurone_data["weights"].map do |value|
              NeuralNets::Weight.new.tap do |weight|
                weight.instance_variable_set(:@value, value)
              end
            end

            bias = NeuralNets::Bias.new.tap do |bias|
              bias.instance_variable_set(:@value, neurone_data["bias"])
            end

            NeuralNets::Neurone.new(0).tap do |neurone|
              neurone.instance_variable_set(:@weights, weights)
              neurone.instance_variable_set(:@bias, bias)
            end
          end

          Layer.new(input_size: 0, output_size: 0).tap do |layer|
            layer.instance_variable_set(:@neurones, neurones)
          end
        end

        NeuralNet.new([0, 0, 0]).tap do |neural_net|
          neural_net.instance_variable_set(:@layers, layers)
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def save(file_path = "./tmp/neural_net.json")
      json = as_json(self).to_json
      File.open(file_path, 'w') { |file| file.write(json) }
    end

    private

    def as_json(neural_net)
      neural_net.layers.map do |layer|
        layer.neurones.map do |neurone|
          {
            weights: neurone.weights.map(&:value),
            bias: neurone.bias.value
          }
        end
      end
    end
  end
end
