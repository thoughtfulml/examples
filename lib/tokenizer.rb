# encoding: utf-8
module Tokenizer
  extend self
  ALPHABET = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a + %w[_ \u0000]).join

  def tokenize(string, &block)
    current_word = ''
    return unless string.respond_to?(:each_char)
    string.each_char do |char|
      if ALPHABET.include?(char)
        current_word += char
      elsif !current_word.empty?
        yield(current_word.downcase)
        current_word = ''
      end
    end

    yield(current_word.downcase) unless current_word.empty?
  end

  def ngram(string, n = 1, &block)
    current_ngram_window = (n-1).times.map { "\u0000" }
    tokenize(string) do |token|
      current_ngram_window << token
      current_ngram_window.shift if current_ngram_window.length == (n + 1)
      block.call(current_ngram_window)
    end
  end

  def unique_tokenizer(string, &block)
    visited = Set.new

    tokenize(string) do |token|
      if visited.include?(token)
      else
        yield(token)
        visited << token
      end
    end
  end

  def cumulative_ngram(string, n = 2, &block)
    ngram(string, n) do |gram|
      n.times do |i|
        block.call(gram[i..-1])
      end
    end
  end
end