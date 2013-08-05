require 'set'
require File.expand_path(File.join(File.dirname(__FILE__), './tokenizer.rb'))
class Language
  attr_reader :name, :characters, :vectors
  def initialize(text_file, name)
    @name = name
    @text_file = text_file
    @vectors, @characters = Tokenizer.tokenize(File.open(@text_file, 'r'))
  end
end