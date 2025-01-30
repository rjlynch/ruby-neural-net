require "ruby-graphviz"

module Graphs
  class Graphviz
    attr_reader :graph

    def initialize(graph)
      @graph = graph
    end

    def to_png(file_path)
      graphviz = GraphViz.new(
        :G,
        rankdir: 'LR',
        type: :digraph,
        nodesep: 0.5,
        ranksep: 100
      )

      graph.edges.each do |edge|
         left_node = graphviz.add_nodes(
           "L##{edge.left.layer}N##{edge.left.neurone}",
           style: "filled",
           color: value_to_color(edge.left.value),
           label: edge.left.value.round(2).to_s,
           fontcolor: font_colour(edge.left.value)
         )

         right_node = graphviz.add_nodes(
           "L##{edge.right.layer}N##{edge.right.neurone}",
           style: "filled",
           color: value_to_color(edge.right.value),
           label: edge.right.value.round(2).to_s,
           fontcolor: font_colour(edge.right.value)
         )

         graphviz.add_edges(
           left_node,
           right_node,
           color: red_green_gradient(edge.value)
         )
      end

      graphviz.output(png: file_path)
    end

    private

    # only use for activations
    def value_to_color(value)
      brightness = (value * 255).clamp(0, 255).round
      hex_brightness = brightness.to_s(16).rjust(2, '0')
      "##{hex_brightness * 3}"
    end

    def red_green_gradient(value)
      value = value.clamp(-1.0, 1.0)

      if value >= 0
        # Green gradient (0 to 1 maps to #808080 -> #00FF00)
        green_intensity = (value * 255).round
        "#00#{green_intensity.to_s(16).rjust(2, '0')}00" # Green color
      else
        # Red gradient (-1 to 0 maps to #808080 -> #FF0000)
        red_intensity = ((-value) * 255).round
        "##{red_intensity.to_s(16).rjust(2, '0')}0000" # Red color
      end
    end

    def font_colour(value)
      value > 0.5 ? "black" : "white"
    end
  end
end
