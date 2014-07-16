require_relative './spec_helper'

describe CorpusSet do
  include TestMacros

  it 'composes two corpuses together' do
    positive = write_training_file('I love this country', 'positive')
    negative = write_training_file('I hate this man', 'negative')
    positive_corp = Corpus.new(positive.path, :positive)
    negative_corp = Corpus.new(negative.path, :negative)

    corpus_set = CorpusSet.new([positive_corp, negative_corp])
    corpus_set.words.must_equal %w[love country hate man]
  end

  it 'returns a set of sparse vectors to train on' do
    positive = write_training_file('I love this country', 'positive')
    negative = write_training_file('I hate this man', 'negative')
    positive_corp = Corpus.new(positive.path, :positive)
    negative_corp = Corpus.new(negative.path, :negative)

    corpus_set = CorpusSet.new([positive_corp, negative_corp])

    expected_ys = [1, -1]
    expected_xes = [[0,1], [2,3]]
    expected_xes.map! do |x|
      Libsvm::Node.features(Hash[x.map {|i| [i, 1]}])
    end

    ys, xes = corpus_set.to_sparse_vectors

    ys.must_equal expected_ys

    xes.flatten.zip(expected_xes.flatten).each do |x, xp|
      x.value.must_equal xp.value
      x.index.must_equal xp.index
    end
  end
end
