def log(epoc_index, batch_index, batch_size, example_index, label, prediction, test: true)
  # Reset correct count if we are on a new batch
  @correct = 0 unless @batch_was == batch_index

  @batch_was = batch_index

  @correct += 1 if prediction == label

  if @correct == 0
    accuracy = 0
  else
    accuracy = ((@correct.to_f / example_index) * 100).round(2)
  end

  percentage_complete = (((1 + example_index.to_f) / batch_size.to_f) * 100).round(2)

  clear = "\e[2K\r "
  itteration = "epoch #{epoc_index} batch #{batch_index}"
  mode = test ? "testing" : "training"
  progress = "#{mode} #{percentage_complete}% complete"
  accuracy = "accuracy: #{accuracy}%"

  print_string = []

  print_string << itteration if test
  print_string << progress
  print_string << accuracy

  print clear
  print print_string.join(" | ")
end

