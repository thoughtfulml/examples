require_relative './spec_helper'

describe Corpus do
  let(:negative) { StringIO.new('I hated that so much') }
  let(:negative_corpus) { Corpus.new(negative, :negative) }
  let(:positive) { StringIO.new('loved movie!! loved') }
  let(:positive_corpus) { Corpus.new(positive, :positive) }

  it 'consumes multiple files and turns it into sparse vectors' do
    negative_corpus.sentiment.must_equal :negative
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
    positive_corpus.sentiment.must_equal :positive
  end

  it 'consumes a positive training set and unique set of words' do
    positive_corpus.words.must_equal Set.new(%w[loved movie])
  end

  it 'defines a sentiment_code of 1 for positive' do
    Corpus.new(StringIO.new(''), :positive).sentiment_code.must_equal 1
  end

  it 'defines a sentiment_code of 1 for positive' do
    Corpus.new(StringIO.new(''), :negative).sentiment_code.must_equal -1
  end
end
