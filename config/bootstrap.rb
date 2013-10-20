require 'bundler'
Bundler.require

require_relative '../lib/corpus'

Redis.new.flushall

Corpus.parse_file("./config/rt-polaritydata/rt-polarity.pos", 1, 5331)
Corpus.parse_file("./config/rt-polaritydata/rt-polarity.neg", -1, 5331)
SentimentModel = Corpus.train_svm!