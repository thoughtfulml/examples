# encoding: utf-8
module Tokenizer
  extend self

  def tokenize(string, &block)
    current_word = ''
    return unless string.respond_to?(:scan)
    string.scan(/[a-zA-Z0-9_\u0000]+/).each do |token|
      yield token.downcase
    end
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
