require './bootstrap'

class FaceQuery < Sinatra::Base
  get '/' do
    erb :home
  end

  post '/similar_face' do
    @image = Image.from_base64(params[:base64image])
    @face = @image.to_face

    # avatar = File.join("/Users/matthewkirk/git/face_query/public", @filepath.fetch(:avatar))
    # _, descriptors = FaceFeatures.features(avatar)
    # @similar_faces = Stats.nearest_neighbor(descriptors).sort_by(&:last)
    'success'
    # erb :similar_face
  end
end