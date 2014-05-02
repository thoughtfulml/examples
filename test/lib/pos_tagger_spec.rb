require 'spec_helper'
require 'tempfile'

describe POSTagger do
  before do
    Redis.new.flushall
  end

  let(:stream) { "A/B C/D C/D A/D A/B ./." }

  let(:stream_file) {
    t = Tempfile.new("sam")  
    t.write(stream)
    t.close
    t.path 
  }
  it 'calculates tag transition probabilities' do
  end

  it 'calculates the probability of a word given a tag' do
    pos_tagger = POSTagger.new([stream_file])
    pos_tagger.train!
    pos_tagger.word_tag_probability("Z", "Z").must_equal 0 
    pos_tagger.word_tag_probability("A", "B").must_equal Rational(2,7)
    pos_tagger.word_tag_probability("A", "D").must_equal Rational(1,7)
    pos_tagger.word_tag_probability("START", "START").must_equal Rational(1,7)
  end
end
