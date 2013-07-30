require 'test/unit'
require 'tempfile'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/language.rb'))

class LanguageTest < Test::Unit::TestCase
  def setup
    @language_data = <<-EOL
    abcdefghijklmnopqrstuvwxyz
    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    \u00A0
    !~.@#$%^&*()_+'?[]“”‘’—<>»«›‹–„/
    ïëéüòèöÄÖßÜøæåÅØóąłżŻśęńŚćźŁ
    EOL
    
    @special_characters = @language_data.split("\n").last.strip
    
    language_file = Tempfile.new('langfile')
    language_file.write(@language_data)
    language_file.close
    
    @language = Language.new(language_file.path, 'English')
  end
  
  def test_alpha_frequencies
    ('a'..'z').to_a.map do |alpha|
      assert_equal 2, @language.frequency_for(alpha), alpha
    end
  end
  
  def test_punctuation_frequencies
    "!~.@#$%^&*()_+'?[]“”‘’—<>»«›‹–„/".split(//).each do |punc|
      assert_equal 0, @language.frequency_for(punc), punc
    end
  end
  
  def test_blank_frequency
    assert_equal 0, @language.frequency_for(' ')
    assert_equal 0, @language.frequency_for("\u00A0") # Unicode Space
  end
  
  def test_special_frequencies
    @special_characters.split(//).each do |special|
      assert_equal 1, @language.frequency_for(special), special
    end
  end
end