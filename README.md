# README
I just made this for myself to learn about back propagation.

If you're looking for a Ruby neural net for your project, check out the
excellent [torch.rb](https://github.com/ankane/torch.rb).

This network is based on what I learnt from the excellent 3 blue 1 brown
[neural net video series](https://www.3blue1brown.com/topics/neural-networks),
specifically [this lesson](https://www.3blue1brown.com/lessons/backpropagation-calculus)

The backprop code is heavily commented to make sure I understood what was going
on. If you spot a bug please let me know!

I built this network without using any matrix multiplication to better
understand what back propagation is actually doing, hence this network is
_slow_, as we can't use the GPU to multiply things in parallel.

To train the network on the full mnist data set (25 epochs * 60,000 images ==
1.5M examples) takes a little over 2 hours on my M1 macbook.

If you're playing around with this you may want to limit the
numbers it learns to recognise by changing the `NUMBERS` array in `test.rb` (or
`train_and_test.rb`).
Learning to differentiate between a 0 and a 1 only takes a few minutes.

![Screenshot 2025-01-10 at 17 56 03](https://github.com/user-attachments/assets/6a4a6db0-4856-423e-b659-eed105651a79)

Predicting either a 0 or a 1

![0-1](https://github.com/user-attachments/assets/4ad12d10-952b-4135-b65f-91222be9803c)



## Getting started
* Clone the repo
* Run bundle to install ChunkyPNG
* Download the training and test data sets from kaggle
  `https://www.kaggle.com/datasets/hojjatk/mnist-dataset`
  and put them in the `./data` directory
* Run `bundle exec ruby train.rb` to train the network.
* Run `bundle exec ruby test.rb` to test the network.

## TODO
- [x] Print images to the terminal using something like iterm's image escape codes
- [x] Store and load weights to / from disk
- [ ] Would love to be able to view the network in graphviz
