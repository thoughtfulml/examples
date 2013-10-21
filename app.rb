require 'yaml'
class SentimentAnalyzer < Sinatra::Base
  POSITIVE = File.open("./config/rt-polaritydata/rt-polarity.pos", "rb").to_a
  NEGATIVE = File.open("./config/rt-polaritydata/rt-polarity.neg", "rb").to_a

  helpers do
    def description(sentence)
      YAML::dump(Corpus.sparse_vector(@sentence).keys)
    end

    def prediction(sentence)
      SentimentModel.predict(Corpus.vector(@sentence))
    end

    def assign_vars(sentence)
      @sentence = sentence
      @description = description(@description)
      @prediction = prediction(@description)
    end
  end

  get '/' do
    @positive = REDIS.get("sentiment_analyzer:rt-polarity.pos:processed")
    @negative = REDIS.get("sentiment_analyzer:rt-polarity.neg:processed")

    erb :home
  end

  post '/sentiment' do
    assign_vars(params[:text_blob])
    erb :sentiment
  end

  get '/random_positive' do
    assign_vars(POSITIVE.sample)
    erb :sentiment
  end

  get '/random_negative' do
    assign_vars(NEGATIVE.sample)
    erb :sentiment
  end
end