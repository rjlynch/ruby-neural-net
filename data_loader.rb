class DataLoader
  def self.images_with_labels(images_path:, labels_path:)
    labels = nil

    File.open(labels_path, "rb") do |file|
      # 'N2' is for two big-endian unsigned 32-bit integers
      magic, _size = file.read(8).unpack('N2')
      unless magic == 2049
        raise "Magic number mismatch, expected 2049, got #{magic}"
      end

      labels = file.read.bytes
    end

    size = nil
    rows = nil
    cols = nil
    image_data = nil

    File.open(images_path, "rb") do |file|
      # 'N4' is for four big-endian unsigned 32-bit integers
      magic, size, rows, cols = file.read(16).unpack('N4')
      unless magic == 2051
        raise "Magic number mismatch, expected 2051, got #{magic}"
      end

      image_data = file.read.bytes
    end

    examples = []

    # 60000 images,
    # image is 28x28 pixels so 784 bytes per image
    size.times do |image_number|
      label = labels[image_number]

      image_data_width = rows * cols

      # read the current offset into the image data for the legnth of the image
      image_start_pointer = image_number * image_data_width
      next_image_start_pointer = (image_number + 1) * image_data_width

      image_bytes = image_data[image_start_pointer...next_image_start_pointer]

      examples << Example.new(image_bytes: image_bytes, label: label)
    end

    examples
  end
end

