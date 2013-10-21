require 'bundler'
Bundler.require

if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new
end

require_relative '../lib/corpus'

Redis.new.flushall

Corpus.parse_file("./config/rt-polaritydata/rt-polarity.pos", 1, 5331)
Corpus.parse_file("./config/rt-polaritydata/rt-polarity.neg", -1, 5331)
SentimentModel = Corpus.train_svm!