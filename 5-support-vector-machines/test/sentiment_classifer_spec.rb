# encoding: utf-8
require_relative './spec_helper'

require 'minitest/mock'

describe SentimentClassifier do
  include TestMacros

  def validate(classifier, file, sentiment)
    total = 0
    misses = 0

    File.open(file, 'rb').each_line do |line|
      if classifier.classify(line) != sentiment
        misses += 1
      else
      end
      total += 1
    end

    Rational(misses, total)
  end

  it 'cross validates with an error of 35% or less' do
    neg = split_file("./config/rt-polaritydata/rt-polarity.neg")
    pos = split_file("./config/rt-polaritydata/rt-polarity.pos")

    classifier = SentimentClassifier.build([
      neg.fetch(:training),
      pos.fetch(:training)
    ])

    # find the minimum

    c = 2 ** 7
    classifier.c = c

    n_er = validate(classifier, neg.fetch(:validation), :negative)
    p_er = validate(classifier, pos.fetch(:validation), :positive)
    total = Rational(
      n_er.numerator + p_er.numerator, 
      n_er.denominator + p_er.denominator
    )

    total.must_be :<, 0.35
  end

  it 'yields a zero error when it uses itself' do
    classifier = SentimentClassifier.build([
      "./config/rt-polaritydata/rt-polarity.neg",
      "./config/rt-polaritydata/rt-polarity.pos"
    ])

    c = 2 ** 7
    classifier.c = c

    n_er = validate(
      classifier, 
      "./config/rt-polaritydata/rt-polarity.neg", 
      :negative
    )

    p_er = validate(
      classifier, 
      "./config/rt-polaritydata/rt-polarity.pos", 
      :positive
    )

    total = Rational(
      n_er.numerator + p_er.numerator, 
      n_er.denominator + p_er.denominator
    )

    total.must_equal 0.0
  end
end
