require 'libsvm'
require 'set'

class Corpus
  STOPWORDS = File.read(
    File.expand_path("../../config/stopwords.txt", __FILE__)
  ).split("\n").map(&:strip)

  STOP_SYMBOL = %w[. ? ! ' "].concat([' ', "\u00A0"])

  attr_reader :sentiment

  def initialize(io, sentiment)
    @io = io
    @sentiment = sentiment
  end

  def sentences(&block)
    @io.each_line do |line|
      yield line
    end
    @io.rewind
  end

  def sentiment_code
    {
      :positive => 1,
      :negative => -1
    }.fetch(@sentiment)
  end

  def self.tokenize(string)
    string.downcase.gsub(/['"\.\?\!]/, '').split(/[[:space:]]/).select do |w|
      !STOPWORDS.include?(w)
    end
  end

  def words
    @words ||= begin
      set = Set.new
      @io.each_line do |line|
        Corpus.tokenize(line).each do |word|
          set << word
        end
      end
      @io.rewind
      set
    end
  end
end
