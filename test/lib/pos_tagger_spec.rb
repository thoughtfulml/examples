require 'spec_helper'
require 'tempfile'

describe POSTagger do
  def training_file(training)
    t = Tempfile.new('training')
    t.write(training)
    t.close
    t.path
  end

  describe 'viterbi' do
    let(:training) { "I/PRO want/V to/TO race/V ./. I/PRO like/V cats/N ./." }
    let(:sentence) { 'I want to race .' }
    let(:pos_tagger) {
      pos_tagger = POSTagger.new([training_file(training)])
      pos_tagger.train!
      pos_tagger
    }

    it 'will calculate the best viterbi sequence for I want to race' do
      pos_tagger.viterbi(sentence).must_equal %w[START PRO V TO V .]
    end
  end

  describe 'probability calculation' do
    let(:stream) { "A/B C/D C/D A/D A/B ./." }

    let(:pos_tagger) {
      pos_tagger = POSTagger.new([training_file(stream)])
      pos_tagger.train!
      pos_tagger
    }

    it 'calculates tag transition probabilities' do
      pos_tagger.tag_probability("Z", "Z").must_equal 0

      # count(previous_tag, current_tag) / count(previous_tag)
      # count D and D happens 2 times, D happens 3 times so 2/3
      pos_tagger.tag_probability("D", "D").must_equal Rational(2,3)
      pos_tagger.tag_probability("START", "B").must_equal 1
      pos_tagger.tag_probability("B", "D").must_equal Rational(1,2)
      pos_tagger.tag_probability(".", "D").must_equal 0
    end

    it 'calculates probability of sequence of words and tags' do
      words = %w[START A C A A .]
      tags = %w[START B D D B .]
      tagger = pos_tagger

      tag_probabilities = [
        tagger.tag_probability("B", "D"),
        tagger.tag_probability("D", "D"),
        tagger.tag_probability("D", "B"),
        tagger.tag_probability("B", ".")
      ].reduce(&:*)

      word_probabilities = [
        tagger.word_tag_probability("A", "B"), # 1
        tagger.word_tag_probability("C", "D"),
        tagger.word_tag_probability("A", "D"),
        tagger.word_tag_probability("A", "B"), # 1
      ].reduce(&:*)

      pos_tagger.probability_of_word_tag(words, tags).must_equal (word_probabilities * tag_probabilities)
    end

    # Maximum Liklihood estimate
    # count (word and tag) / count(tag)
    it 'calculates the probability of a word given a tag' do
      pos_tagger.word_tag_probability("Z", "Z").must_equal 0

      # A and B happens 2 times, count of b happens twice therefore 100%
      pos_tagger.word_tag_probability("A", "B").must_equal 1

      # A and D happens 1 time, count of D happens 3 times so 1/3
      pos_tagger.word_tag_probability("A", "D").must_equal Rational(1,3)

      # START and START happens 1, time, count of start happens 1 so 1
      pos_tagger.word_tag_probability("START", "START").must_equal 1

      pos_tagger.word_tag_probability(".", ".").must_equal 1
    end
  end
end
