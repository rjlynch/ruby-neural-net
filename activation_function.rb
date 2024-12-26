SIGMOID = ->(x) { 1 / (1 + Math.exp(-x)) }
SIGMOID_DERIVATIVE = ->(z) { SIGMOID.(z) * (1 - SIGMOID.(z)) }

