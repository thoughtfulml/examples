require 'yaml'
class SentimentAnalyzer < Sinatra::Base
  REDIS = Redis.new
  POSITIVE = File.open("./config/rt-polaritydata/rt-polarity.pos", "rb").to_a
  NEGATIVE = File.open("./config/rt-polaritydata/rt-polarity.neg", "rb").to_a

  get '/' do
    @positive = REDIS.get("sentiment_analyzer:rt-polarity.pos:processed")
    @negative = REDIS.get("sentiment_analyzer:rt-polarity.neg:processed")

    erb :home
  end

  post '/sentiment' do
    @sentence = params[:text_blob]
    @description = YAML::dump(Corpus.sparse_vector(@sentence).keys)
    @prediction = SentimentModel.predict(Corpus.vector(@sentence))
    erb :sentiment
  end

  get '/random_positive' do
    @sentence = POSITIVE.sample
    @description = YAML::dump(Corpus.sparse_vector(@sentence).keys)
    @prediction = SentimentModel.predict(Corpus.vector(@sentence))
    erb :sentiment
  end

  get '/random_negative' do
    @sentence = NEGATIVE.sample
    @description = YAML::dump(Corpus.sparse_vector(@sentence).keys)
    @prediction = SentimentModel.predict(Corpus.vector(@sentence))
    erb :sentiment
  end
end