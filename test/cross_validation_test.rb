require 'minitest/autorun'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/network.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/language.rb'))

puts "Bootstrapping Neural Network"
@languages = []
@cross_validation_languages = []

Dir[File.expand_path(File.join(File.dirname(__FILE__), './data/*.txt'))].each do |txt|
  if txt =~ /_1\.txt/
    @cross_validation_languages << Language.new(txt, File.basename(txt, '.txt').split("_").first)
  else
    @languages << Language.new(txt, File.basename(txt, '.txt'))
  end
end

MATTHEW_VERSES = Network.new(@languages)
MATTHEW_VERSES.train!
ACTS_VERSES = Network.new(@cross_validation_languages)
ACTS_VERSES.train!

describe Network do
  def compare(network, text_file)
    misses = 0
    hits = 0

    file = File.read(text_file)
    file.split(/[\.!\?]/).each do |sentence|
      if network.run(sentence).name == File.basename(text_file, '.txt').split("_").first
        hits += 1
      else
        misses += 1
      end
    end

    assert misses < (0.05 * (misses + hits)), "#{text_file} has failed with a miss rate of #{misses.to_f / (misses + hits)}"
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