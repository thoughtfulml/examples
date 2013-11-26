require 'base64'
require './lib/face'

class FaceQuery < Sinatra::Base
  get '/' do
    erb :home
  end

  post '/similar_face' do
    @filepath = Face.from_base64(params[:base64image])
    erb :similar_face
  end
end