require 'minitest/autorun'
require File.expand_path('../../lib/network.rb', __FILE__)
require File.expand_path('../../lib/language.rb', __FILE__)

puts "Bootstrapping Neural Network"
@languages = []
@cross_validation_languages = []

Dir[File.expand_path('../data/*.txt', __FILE__)].each do |txt|
  if txt =~ /_1\.txt/
    @cross_validation_languages << Language.new(
      txt, 
      File.basename(txt, '.txt').split("_").first
    )
  else
    @languages << Language.new(
      txt, 
      File.basename(txt, '.txt').split("_").firsti
    )
  end
end

MATTHEW_VERSES = Network.new(@languages)
MATTHEW_VERSES.train!
ACTS_VERSES = Network.new(@cross_validation_languages)
ACTS_VERSES.train!

describe Network do
  def compare(network, text_file)
    misses = 0.0
    hits = 0.0

    file = File.read(text_file)
    file.split(/[\.!\?]/).each do |sentence|
      sentence_name = network.run(sentence).name

      expected = File.basename(text_file, '.txt').split('_').first
      if sentence_name = expected 
        hits += 1
      else
        misses += 1
      end
    end

    total = misses + hits

    assert(
      misses < (0.05 * total), 
      "#{text_file} has failed with a miss rate of #{misses / total}"
    )
  end

  def language_test(language)
    compare(MATTHEW_VERSES, "./test/data/#{language}_1.txt")
    compare(ACTS_VERSES, "./test/data/#{language}_0.txt")
  end

  %w[English Finnish German Norwegian Polish Swedish].each do |lang|
    it "Trains and cross-validates with an error of 5% for #{lang}" do
      language_test(lang)
    end
  end
end
