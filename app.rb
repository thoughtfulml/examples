require 'yaml'
class SentimentAnalyzer < Sinatra::Base
  POSITIVE = File.open("./config/rt-polaritydata/rt-polarity.pos", "rb").to_a
  NEGATIVE = File.open("./config/rt-polaritydata/rt-polarity.neg", "rb").to_a

  helpers do
    def prediction(sentence)
      SentimentModel.classify(@sentence)
    end

    def assign_vars(sentence)
      @sentence = sentence
      @prediction = prediction(@description)
    end
  end

  get '/' do
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