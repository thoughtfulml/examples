require './config/bootstrap'

class FaceQuery < Sinatra::Base
  FACES = Dir['./public/att_faces/**/*.png']

  FACE_NEIGHBORHOOD = Neighborhood.new(FACES)

  helpers do
    def image_url(absolute_path)

      pub_observed = false

      parts = []
      absolute_path.split("/").each do |part|
        if pub_observed
          parts << part
        else
          pub_observed = (part == 'public')
        end
      end

      File.join(*parts)
    end
  end

  get '/' do
    erb :home
  end

  get '/random' do
    random_face = FACES.sample
    @image = Struct.new(:filepath).new(random_face)
    @face = Face.new(random_face)
    @guess = FACE_NEIGHBORHOOD.attributes_guess(@face.filepath)

    @glasses_inclination = @guess.fetch('glasses').max_by(&:last).first
    @facial_hair_inclination = @guess.fetch('facial_hair').max_by(&:last).first

    erb :similar_face
  end

  post '/similar_face' do
    @image = Image.from_base64(params[:base64image])
    @face = @image.to_face
    @guess = FACE_NEIGHBORHOOD.attributes_guess(@face.filepath)

    @glasses_inclination = @guess.fetch('glasses').max_by(&:last).first
    @facial_hair_inclination = @guess.fetch('facial_hair').max_by(&:last).first

    erb :similar_face
  end
end