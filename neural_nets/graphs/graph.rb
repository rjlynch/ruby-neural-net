require "json"
require_relative "edge"
require_relative "node"

module Graphs
  class Graph
    def self.load(path)
      json = File.read(path)

      edges = JSON.parse(json, symbolize_names: true).map do |edge|
        left = Node.new(
          value: edge[:left][:value],
          layer: edge[:left][:layer],
          neurone: edge[:left][:neurone]
        )

        right = Node.new(
          value: edge[:right][:value],
          layer: edge[:right][:layer],
          neurone: edge[:right][:neurone]
        )

        Edge.new(left: left, right: right, value: edge[:value])
      end

      new(nil).tap { |graph| graph.instance_variable_set(:@edges, edges) }
    end

    def initialize(neural_net)
      @neural_net = neural_net
    end

    def save(path)
      File.write(path, JSON.pretty_generate(as_json))
    end

    def edges
      @edges ||= build_graph
    end

    private

    def as_json
      edges.map(&:as_json)
    end

    def build_graph
      activations = []
      # Activation for layer L - 1 is stored as the input to the weights in
      # layer L. We don't store the input layer activation so we'll have to
      # pull it out of the first hidden layer's weights to rebuild it.
      # Remember a neurone has a weight for each neurone in the previous layer.
      input_activation = @neural_net
        .layers
        .first
        .neurones
        .first
        .weights
        .map(&:input)

      activations << input_activation

      # We do store the hidden and output layer activations
      @neural_net.layers.map(&:neurones).each do |neurones|
        activations << neurones.map(&:activation)
      end

      nodes = []

      activations.each_with_index do |layer, i|
        nodes << layer.map.with_index do |activation, j|
          Node.new(value: activation, layer: i, neurone: j)
        end
      end

      edges = []

      nodes.each_cons(2) do |l1_nodes, l2_nodes|
        l1_nodes.each do |l1_node|
          l2_nodes.each do |l2_node|
            edges << Edge.new(
              left: l1_node,
              right: l2_node,
              value: @neural_net.layers[l2_node.layer - 1].neurones[l2_node.neurone].weights[l1_node.neurone].value
            )
          end
        end
      end

      edges
    end
  end
end

