require_relative './lib/network'
require_relative './lib/language'
require 'yaml'
require 'json'

Thread.new do
  @languages = []
  LANGUAGE_SENTENCES = {}
  Dir[File.expand_path("../test/data/*.txt", __FILE__)].each do |txt|
    next if txt =~ /_1\.txt/
    lang_name = File.basename(txt, '.txt').split("_").first.downcase

    LANGUAGE_SENTENCES[lang_name] ||= []

    File.read(txt).split(/[\.\?!]+/).each_with_index do |sent, i|
      if i % 10 == 0
        LANGUAGE_SENTENCES[lang_name] << sent
      end
    end

    @languages << Language.new(txt, lang_name.capitalize)
  end
  CLASSIFIER = Network.new(@languages)
  CLASSIFIER.train!
end

class LanguageClassifier < Sinatra::Base
  SWEDISH_CHEF = File.read("./swedish_chef_quotes.txt").split("\n")

  get '/' do
    erb :home
  end

  get '/swedish_chef' do
    @sentence = SWEDISH_CHEF.sample
    @classified_lang = CLASSIFIER.run(@sentence).name
    erb :language
  end

  get '/:language' do
    @sentence = LANGUAGE_SENTENCES.fetch(params[:language], []).sample
    @classified_lang = CLASSIFIER.run(@sentence).name
    erb :language
  end

  post '/classify' do
    content_type :json
    { 'language' => CLASSIFIER.run(params[:text_blob].to_s).name }.to_json
  end
end