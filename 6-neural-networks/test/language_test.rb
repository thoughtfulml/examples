# encoding: utf-8
require 'minitest/autorun'
require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/language.rb'))

describe Language do
  before do
    @language_data = <<-EOL
    abcdefghijklmnopqrstuvwxyz.
    ABCDEFGHIJKLMNOPQRSTUVWXYZ.
    \u00A0.
    !~@#$\%^&*()_\+'?[]“”‘’—<>»«›‹–„/.
    ïëéüòèöÄÖßÜøæåÅØóąłżŻśęńŚćźŁ.
    EOL

    @special_characters = @language_data.split("\n").last.strip

    @language_file = Tempfile.new('langfile')
    @language_file.write(@language_data)
    @language_file.close

    @language = Language.new(@language_file.path, 'English')
  end

  after do
    @language_file.unlink
  end

  it 'has the proper keys for each vector' do
    @language.vectors.first.keys.must_equal ('a'..'z').to_a
    @language.vectors[1].keys.must_equal ('a'..'z').to_a

    special_chars = "ïëéüòèöäößüøæååØóąłżżśęńśćźŁ".split(//).uniq.sort

    @language.vectors.last.keys.sort.must_equal special_chars
  end

  it 'sums to 1 for all vectors' do
    @language.vectors.each do |vector|
      vector.values.inject(&:+).must_equal 1
    end
  end

  it 'returns characters that is a unique set of characters used' do
    chars = ('a'..'z').to_a
    chars.concat "ïëéüòèöäößüøæååØóąłżżśęńśćźŁ".split(//).uniq

    @language.characters.to_a.sort.must_equal chars.sort
  end
end
