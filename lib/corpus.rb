require 'libsvm'
require 'set'

class Corpus
  STOPWORDS = File.read(
    File.expand_path("../../config/stopwords.txt", __FILE__)
  ).split("\n").map(&:strip)

  STOP_SYMBOL = %w[. ? ! ' "].concat([' ', "\u00A0"])

  attr_reader :sentiment

  def initialize(file, sentiment)
    @file = file
    @sentiment = sentiment
  end

  def sentences(&block)
    File.open(@file, 'rb').each_line do |line|
      yield line
    end
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
      File.open(@file, 'rb').each_line do |line|
        Corpus.tokenize(line).each do |word|
          set << word
        end
      end
      set
    end
  end
end