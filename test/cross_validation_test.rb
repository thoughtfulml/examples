require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/network.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/language.rb'))

@languages = []
@cross_validation_languages = []

Dir[File.expand_path(File.join(File.dirname(__FILE__), './data/*.txt'))].each do |txt|
  if txt =~ /_1\.txt/
    @cross_validation_languages << Language.new(txt, File.basename(txt, '.txt').split("_").first)
  else
    @languages << Language.new(txt, File.basename(txt, '.txt'))
  end
end

LANGUAGE_NETWORK = Network.new(@languages)
LANGUAGE_NETWORK.train!
CROSS_VAL_NETWORK = Network.new(@cross_validation_languages)
CROSS_VAL_NETWORK.train!

class CrossValidationTest < Test::Unit::TestCase
  def compare(network, text_file)
    misses = 0
    hits = 0

    file = File.read(text_file)
    file.split(/[\.!\?]/).each do |sentence|
      if network.run(sentence).name.split("_").first == File.basename(text_file, '.txt').split("_").first
        hits += 1
      else
        misses += 1
      end
    end
    assert misses < (0.05 * (misses + hits)), "#{text_file} has failed with a miss rate of #{misses.to_f / (misses + hits)}"
  end

  def language_test(language)
    compare(LANGUAGE_NETWORK, "./test/data/#{language}_1.txt")
    compare(CROSS_VAL_NETWORK, "./test/data/#{language}_0.txt")
  end

  %w[Dutch English Finnish German Norwegian Polish Swedish].each do |lang|
    define_method "test_#{lang.downcase}" do
      language_test(lang)
    end
  end
end