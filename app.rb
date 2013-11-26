require 'base64'
require './lib/face'
require './lib/stats'

class FaceQuery < Sinatra::Base
  get '/' do
    erb :home
  end

  post '/similar_face' do
    @filepath = Face.from_base64(params[:base64image])
    avatar = File.join("/Users/matthewkirk/git/face_query/public", @filepath.fetch(:avatar))
    _, descriptors = FaceFeatures.features(avatar)
    @similar_faces = Stats.nearest_neighbor(descriptors).sort_by(&:last)
    erb :similar_face
  end
end