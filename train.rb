require "base64"
require "json"
require "chunky_png"
require_relative "activation_function"
require_relative "example"
require_relative "data_loader"
require_relative "neural_nets/bias"
require_relative "neural_nets/weight"
require_relative "neural_nets/neurone"
require_relative "neural_nets/layer"
require_relative "neural_nets/persistence"
require_relative "neural_nets/neural_net"
require_relative "logging"

# Subset of mnist digits to learn to recognize
NUMBERS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# Hyper parameters
BATCH_SIZE = 128

EPOCS = 25

LEARNING_RATE = 0.1

# Set up our neural net with 784 input neurones (28x28 pixels)
# 16 neurones in each of the hidden layers
# and NUMBERS.size output neurones, one for each digit we want to recognize.
neural_net = NeuralNets::NeuralNet.new([784, 16, 16, NUMBERS.size])

# Load our data sets
trainning_examples = DataLoader.images_with_labels(
  images_path: "data/train-images.idx3-ubyte",
  labels_path: "data/train-labels.idx1-ubyte"
)

trainning_examples = trainning_examples.select { |e| NUMBERS.include? e.label }

puts "Training neural net to recognize digits #{NUMBERS.join(", ")}"

# Training loop
EPOCS.times.with_index do |epoc, ei|
  trainning_examples.shuffle.each_slice(BATCH_SIZE).each_with_index do |batch, bi|
    batch.each_with_index do |example, i|
      input = example.image_bytes

      target = Array.new(NUMBERS.size) { 0 }.tap { |a| a[example.label] = 1 }

      prediction = neural_net.train(x: input, y: target)

      log(ei, bi, BATCH_SIZE, i, example.label, prediction)
    end

    # Update the weights and biases after each batch
    neural_net.learn!(LEARNING_RATE)

    puts
  end
end

neural_net.save

puts "Training complete"
