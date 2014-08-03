# encoding: utf-8
require 'minitest/autorun'
require File.expand_path('../../lib/network.rb', __FILE__)
require File.expand_path('../../lib/language.rb', __FILE__)

networks = {}

describe Network do
  def language_name(text_file)
    File.basename(text_file, '.txt').split('_').first
  end

  def compare(network, text_file)
    misses = 0.0
    hits = 0.0

    file = File.read(text_file)

    file.split(/[\.!\?]/).each do |sentence|
      sentence_name = network.run(sentence).name

      if sentence_name == language_name(text_file)
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

  def load_glob(glob)
    Dir[File.expand_path(glob, __FILE__)].map do |m|
      Language.new(File.open(m, 'r+'), language_name(m))
    end
  end

  let(:matthew_languages) { load_glob('../../data/*_0.txt') }
  let(:acts_languages) { load_glob('../../data/*_1.txt') }
  let(:matthew_verses) {
    networks[:matthew] ||= Network.new(matthew_languages).train!
    networks[:matthew]
  }

  let(:acts_verses) {
    networks[:acts] ||= Network.new(acts_languages).train!
    networks[:acts]
  }

  %w[English Finnish German Norwegian Polish Swedish].each do |lang|
    it "Trains and cross-validates with an error of 5% for #{lang}" do
      compare(matthew_verses, "./data/#{lang}_1.txt")
      compare(acts_verses, "./data/#{lang}_0.txt")
    end
  end
end
