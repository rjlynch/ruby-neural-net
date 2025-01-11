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

neural_net = NeuralNets::NeuralNet.load

# How many numbers the neural net was trained to recognize
# Set the NUMBERS constant in train.rb to change how many digits the neural net
# is trained to recognize. You may want to set this to [0, 1] for quick testing
numbers = neural_net.layers.last.neurones.size.times.to_a

test_examples = DataLoader.images_with_labels(
  images_path: "data/t10k-images.idx3-ubyte",
  labels_path: "data/t10k-labels.idx1-ubyte"
)

# Select examples that the neural net was trained to recognize
test_examples = test_examples.select { |e| numbers.include? e.label }

# Testing loop
correct = 0

puts "Testing neural net trained to recognize digits #{numbers.join(", ")}"

test_examples_size = test_examples.size

failed = []

test_examples.each_with_index do |example, index|
  index = index + 1
  prediction = neural_net.predict(example.image_bytes)
  if prediction == example.label
    correct += 1
  else
    failed << { example: example, prediction: prediction }
  end

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
