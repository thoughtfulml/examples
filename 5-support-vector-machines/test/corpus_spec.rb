require_relative './spec_helper'

describe Corpus do
  include TestMacros

  it 'consumes multiple files and turns it into sparse vectors' do
    negative = write_training_file("I hated that so much", 'negative')
    corpus = Corpus.new(negative.path, :negative)
    corpus.sentiment.must_equal :negative
  end

  describe "tokenize" do
    it "downcases all the word tokens" do
      Corpus.tokenize("Quick Brown Fox").must_equal %w[quick brown fox]
    end

    it "ignores all stop symbols" do
      Corpus.tokenize("\"'hello!?!?!.'\"  ").must_equal %w[hello]
    end

    it "ignores the unicode space" do
      Corpus.tokenize("hello\u00A0bob").must_equal %w[hello bob]
    end
  end

  it 'consumes a positive training set' do
    positive = write_training_file("I loved that movie so much", 'positive')
    corpus = Corpus.new(positive.path, :positive)
    corpus.sentiment.must_equal :positive
  end

  it 'consumes a positive training set and unique set of words' do
    positive = write_training_file('I loved that so much!!! I loved it', 'positive')
    corpus = Corpus.new(positive.path, :positive)
    corpus.words.must_equal Set.new(%w[loved])
  end

  it 'defines a sentiment_code of 1 for positive' do
    Corpus.new('/dev/null', :positive).sentiment_code.must_equal 1
  end

  it 'defines a sentiment_code of 1 for positive' do
    Corpus.new('/dev/null', :negative).sentiment_code.must_equal -1
  end
end