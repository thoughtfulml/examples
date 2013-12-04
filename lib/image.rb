require 'base64'
class Image
  HAAR_FILEPATH = './data/haarcascade_frontalface_alt.xml'
  FACE_DETECTOR = OpenCV::CvHaarClassifierCascade::load(HAAR_FILEPATH)

  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
    @face_found = false
  end

  def self.from_base64(base64)
    encoded_data = Base64.decode64(base64)
    filepath = File.join("/Users/matthewkirk/git/face_query/public/faces", SecureRandom.hex) + ".jpg"
    File.open(filepath, 'wb') {|f| f.write(encoded_data)}
    image = MiniMagick::Image.open(filepath)
    image.colorspace 'Gray'
    image.write(filepath)
    new(filepath)
  end

  def face_region
    @image = OpenCV::CvMat.load(@filepath, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
    FACE_DETECTOR.detect_objects(@image).first
  end

  def to_face
    region = face_region
    top_left = region.top_left
    bottom_right = region.bottom_right

    x_size = bottom_right.x - top_left.x
    y_size = bottom_right.y - top_left.y

    crop_params = "#{x_size - 1}x#{y_size-1}+#{top_left.x + 1}+#{top_left.y + 1}"
    image = MiniMagick::Image.open(@filepath)

    image.crop crop_params

    outfile = File.join("/Users/matthewkirk/git/face_query/public/faces", "avatar_" + File.basename(@filepath))
    image.write(outfile)
    Face.new("./public/faces/" + File.basename(outfile))
  end
end