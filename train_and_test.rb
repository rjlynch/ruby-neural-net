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

test_examples = DataLoader.images_with_labels(
  images_path: "data/t10k-images.idx3-ubyte",
  labels_path: "data/t10k-labels.idx1-ubyte"
)

test_examples = test_examples.select { |e| NUMBERS.include? e.label }

# Training loop
EPOCS.times do |epoc|
  epoc = epoc + 1
  trainning_examples.shuffle.each_slice(BATCH_SIZE).each_with_index do |batch, bi|
    batch_no = bi + 1

    correct = 0

    batch.each_with_index do |example, index|
      index = index + 1
      input = example.image_bytes
      target = Array.new(NUMBERS.size) { 0 }.tap { |a| a[example.label] = 1 }
      prediction = neural_net.train(x: input, y: target)

      correct += 1 if prediction == example.label

      if correct == 0
        accuracy = 0
      else
        accuracy = ((correct.to_f / index) * 100).round(2)
      end

      percentage_complete = ((index.to_f / batch.size.to_f) * 100).round(2)

      print \
        "\e[2K\r " \
        "epoch #{epoc} batch #{batch_no} | " \
        "training #{percentage_complete}% complete | " \
        "accuracy: #{accuracy}%"
    end

    # Update the weights and biases after each batch
    neural_net.learn!(LEARNING_RATE)

    puts
  end
end

puts
puts

# Testing loop
correct = 0

test_examples_size = test_examples.size

test_examples.each_with_index do |example, index|
  index = index + 1
  prediction = neural_net.predict(example.image_bytes)
  correct += 1 if prediction == example.label

  percentage_complete = ((index.to_f / test_examples_size.to_f) * 100).round(2)

  if correct == 0
    accuracy = 0
  else
    accuracy = ((correct.to_f / index) * 100).round(2)
  end

  accuracy = ((correct.to_f / index) * 100).round(2)

  print "\e[2K\r " \
    "testing #{percentage_complete}% complete | " \
    "accuracy: #{accuracy}%"
end

puts
total_accuracy = ((correct / test_examples_size.to_f) * 100).round(2)
puts "Accuracy: #{total_accuracy}%"
