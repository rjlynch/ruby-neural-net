class Example
  attr_reader :image_bytes, :label

  def initialize(image_bytes:, label:)
    @image_bytes = image_bytes
    @label = label
  end

  def open
    image.save(filename)

    system("open #{filename}")
  end

  def filename
    "./tmp/mnist_digit.png"
  end

  def display
    unless ENV['TERM_PROGRAM'] == 'iTerm.app'
      puts "This feature is supported only in iTerm2."
      return
    end

    image.save(filename)
    png_data = File.binread(filename)

    # iTerm2 escape sequence to display image
    puts "\e]1337;File=inline=1;width=auto;height=auto;preserveAspectRatio=1:#{Base64.strict_encode64(png_data)}\a"
  end

  private

  def image
    return @image if @image

    @image = ChunkyPNG::Image.new(28, 28, ChunkyPNG::Color::WHITE)

    image_bytes.each_with_index do |byte, index|
      x = index % 28
      y = index / 28
      @image[x, y] = ChunkyPNG::Color.grayscale(byte)
    end

    @image
  end
end

