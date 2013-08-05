require 'test/unit'
require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/language.rb'))

class LanguageTest < Test::Unit::TestCase
  def setup
    @language_data = <<-EOL
    abcdefghijklmnopqrstuvwxyz.
    ABCDEFGHIJKLMNOPQRSTUVWXYZ.
    \u00A0.
    !~@#$%^&*()_+'?[]“”‘’—<>»«›‹–„/.
    ïëéüòèöÄÖßÜøæåÅØóąłżŻśęńŚćźŁ.
    EOL

    @special_characters = @language_data.split("\n").last.strip

    language_file = Tempfile.new('langfile')
    language_file.write(@language_data)
    language_file.close

    @language = Language.new(language_file.path, 'English')
  end

  def test_vectors
    assert_equal ('a'..'z').to_a, @language.vectors.first.keys
    assert_equal ('a'..'z').to_a, @language.vectors[1].keys

    special_chars = "ïëéüòèöäößüøæååØóąłżżśęńśćźŁ".split(//).uniq.sort
    assert_equal special_chars, @language.vectors.last.keys.sort
  end

  def test_to_vector_sums_up_to_1
    @language.vectors.each do |vector|
      assert_equal 2 - vector.values.length, vector.values.inject(&:+), vector
    end
  end

  def test_characters
    chars = ('a'..'z').to_a
    chars.concat "ïëéüòèöäößüøæååØóąłżżśęńśćźŁ".split(//).uniq

    assert_equal chars.sort, @language.characters.to_a.sort
  end

  def test_to_vector
    # frequency_sum = @language.frequencies.values.inject(&:+)
    # vector = @language.to_vector
    #
    # @language.frequencies.keys.sort.each do |char|
    #   assert_equal vector.fetch(char), @language.frequency_for(char) / frequency_sum.to_f
    # end
  end

  # def test_alpha_frequencies
  #   ('a'..'z').to_a.map do |alpha|
  #     assert_equal 2, @language.frequency_for(alpha), alpha
  #   end
  # end
  #
  # def test_punctuation_frequencies
  #   "!~.@#$%^&*()_+'?[]“”‘’—<>»«›‹–„/".split(//).each do |punc|
  #     assert_equal 0, @language.frequency_for(punc), punc
  #   end
  # end
  #
  # def test_blank_frequency
  #   assert_equal 0, @language.frequency_for(' ')
  #   assert_equal 0, @language.frequency_for("\u00A0") # Unicode Space
  # end
  #
  # def test_special_frequencies
  #   @special_characters.split(//).each do |special|
  #     assert_equal 1, @language.frequency_for(special), special
  #   end
  # end
end