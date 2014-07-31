require 'minitest/autorun'
require 'tempfile'
require 'mocha/setup'

Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each {|_| require _ }

module TestMacros
  def write_training_file(text, sentiment)
    file = Tempfile.new(sentiment)
    file.write(text)
    file.close
    file
  end

  def split_file(filepath)
    ext = File.extname(filepath)
    validation = File.open("./test/fixtures/validation#{ext}", "wb")
    training = File.open("./test/fixtures/training#{ext}", "wb")

    counter = 0
    File.open(filepath, 'rb').each_line do |l|
      if (counter) % 2 == 0
        validation.write(l)
      else
        training.write(l)
      end
      counter += 1
    end
    training.close
    validation.close

    {
      :training => training.path,
      :validation => validation.path
    }
  end
end
