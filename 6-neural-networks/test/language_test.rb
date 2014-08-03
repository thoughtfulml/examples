# encoding: utf-8
require 'minitest/autorun'
require 'tempfile'
require File.expand_path('../../lib/language.rb', __FILE__)
require 'stringio'

describe Language do
  let(:language_data) {
    <<-EOL
    abcdefghijklmnopqrstuvwxyz.
    ABCDEFGHIJKLMNOPQRSTUVWXYZ.
    \u00A0.
    !~@#$\%^&*()_\+'?[]“”‘’—<>»«›‹–„/.
    ïëéüòèöÄÖßÜøæåÅØóąłżŻśęńŚćźŁ.
    EOL
  }

  let(:special_characters) { language_data.split("\n").last.strip }

  let(:language_io) { StringIO.new(language_data) }

  let(:language) { Language.new(language_io, 'English') }

  it 'has the proper keys for each vector' do
    language.vectors.first.keys.must_equal ('a'..'z').to_a
    language.vectors[1].keys.must_equal ('a'..'z').to_a

    special_chars = "ïëéüòèöäößüøæååØóąłżżśęńśćź".split(//).uniq.sort

    language.vectors.last.keys.sort.must_equal special_chars
  end

  it 'sums to 1 for all vectors' do
    language.vectors.each do |vector|
      vector.values.inject(&:+).must_equal 1
    end
  end

  it 'returns characters that is a unique set of characters used' do
    chars = ('a'..'z').to_a
    chars.concat "ïëéüòèöäößüøæååØóąłżżśęńśćź".split(//).uniq

    language.characters.to_a.sort.must_equal chars.sort
  end
end
