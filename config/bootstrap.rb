require 'bundler'
Bundler.require

require_relative '../lib/corpus'
require_relative '../lib/corpus_set'
require_relative '../lib/sentiment_classifier'

files = [
  "./config/rt-polaritydata/rt-polarity.pos",
  "./config/rt-polaritydata/rt-polarity.neg"
]
SentimentModel = SentimentClassifier.build(files)
