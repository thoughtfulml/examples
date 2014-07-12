require_relative '../spec_helper'

describe SpamTrainer do
  let(:training) do
    [['spam','./test/fixtures/plain.eml'], ['ham','./test/fixtures/small.eml']]
  end

  let(:trainer) { SpamTrainer.new(training)}

  describe 'initialization' do
    let(:hash_test) do
      {'spam' => './filepath', 'ham' => './another', 'scram' => './another2'}
    end
    it 'allows you to pass in multiple categories' do
      st = SpamTrainer.new(hash_test)
      st.categories.sort.must_equal hash_test.keys.uniq.sort
    end

    it 'initializes counts all at 0 plus an _all category' do
      st = SpamTrainer.new(hash_test)
      %w[_all spam ham scram].each do |cat|
        st.total_for(cat).must_equal 0
      end
    end
  end

  describe 'scoring and classification' do
    let (:training) do
      [
        ['spam','./test/fixtures/plain.eml'],
        ['ham','./test/fixtures/plain.eml'],
        ['scram','./test/fixtures/plain.eml']
      ]
    end

    let(:trainer) do
      SpamTrainer.new(training)
    end

    let(:email) { Email.new('./test/fixtures/plain.eml') }

    it 'sets the preference based on how many times a category shows up' do
      trainer.preference.must_equal trainer.categories.sort_by {|cat| trainer.total_for(cat) }
    end

    it 'always passes in an object that has blob defined on it otherwise error' do
      -> {trainer.score(Struct)}.must_raise RuntimeError
    end

    it 'calculates the probability to be exactly 1/n of the categories for itself' do
      trainer.score(email).values.uniq.length.must_equal 1
    end

    it 'calculates the probability to be exactly the same and add up to 1' do
      trainer.normalized_score(email).values.inject(&:+).must_equal 1
      trainer.normalized_score(email).values.first.must_equal Rational(1,3)
    end

    it 'gives preference to whatever has the most in it' do
      score = trainer.score(email)
      preference = trainer.preference.last

      trainer.classify(email).must_equal SpamTrainer::Classification.new(preference, score.fetch(preference))
    end
  end

  describe 'entropy' do
    it 'calculates entropy' do
      # Entropy is the sum of probabilities
      # times the log2 of itself
      entropy = 0.0
      trainer.train!
      training = trainer.instance_variable_get("@training")

      trainer.categories.each do |cat|
        hash = training.fetch(cat)
        hash.each do |token, count|
          prob = Rational(count.to_i, trainer.total_for("_all"))
          entropy += prob * Math::log2(prob)
        end
      end

      trainer.entropy.wont_equal 0.0
      trainer.entropy.must_equal entropy
    end

    describe 'perplexity' do
      it 'calculates perplexity as 2 ** -entropy' do
        trainer.perplexity.wont_equal 0.0
        trainer.perplexity.must_equal (2 ** (-trainer.entropy))
      end
    end
  end
end