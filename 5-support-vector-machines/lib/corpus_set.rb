require 'libsvm'
class CorpusSet

  attr_reader :words

  def initialize(corpora)
    @corpora = corpora
    @words = corpora.reduce(Set.new) do |set, corpus|
      set.merge(corpus.words)
    end.to_a
  end

  def to_sparse_vectors
    calculate_sparse_vectors!
    [@yes, @xes]
  end

  def sparse_vector(string)
    vector = Hash.new(0)
    Corpus.tokenize(string).each do |token|
      vector[@words.to_a.index(token)] = 1
    end

    Libsvm::Node.features(vector)
  end

  private
  def calculate_sparse_vectors!
    return if @state == :calculated
    @yes = []
    @xes = []
    @corpora.each do |corpus|
      vectors = load_corpus(corpus)
      @xes.concat(vectors)
      @yes.concat([corpus.sentiment_code] * vectors.length)
    end
    @state = :calculated
  end

  def load_corpus(corpus)
    vectors = []
    corpus.sentences do |sentence|
      vectors << sparse_vector(sentence)
    end
    vectors
  end
end
