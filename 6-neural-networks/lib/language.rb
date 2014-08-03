#encoding: utf-8
require 'set'
require File.expand_path('../tokenizer.rb', __FILE__)
class Language
  attr_reader :name, :characters, :vectors
  def initialize(language_io, name)
    @name = name
    @vectors, @characters = Tokenizer.tokenize(language_io)
  end
end
