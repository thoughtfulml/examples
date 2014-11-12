require 'base64'
class Image
  HAAR_FILEPATH = './data/haarcascade_frontalface_alt.xml'
  FACE_DETECTOR = OpenCV::CvHaarClassifierCascade::load(HAAR_FILEPATH)

  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
  end

  def self.write(filepath)
    if File.exists?(filepath)
    else
      yield
    end
    filepath
  end

  def self.from_base64(base64)
    filepath = "./public/faces/#{Digest::MD5.hexdigest(base64)}.jpg"

    write(filepath) do
      encoded_data = Base64.decode64(base64)
      image = MiniMagick::Image.read(encoded_data)
      image.colorspace 'Gray'
      image.write(filepath)
    end

    new(filepath)
  end

  def face_region
    @image = OpenCV::CvMat.load(@filepath, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
    FACE_DETECTOR.detect_objects(@image).first
  end

  def to_face
    name = File.basename(@filepath)
    outfile = File.expand_path("../../public/faces/avatar_#{name}", __FILE__)

    self.class.write(outfile) do
      image = MiniMagick::Image.open(@filepath)
      image.crop(crop_params)
      image.write(outfile)
    end

    Face.new(outfile)
  end

  def x_size
    face_region.bottom_right.x - face_region.top_left.x
  end

  def y_size
    face_region.bottom_right.y - face_region.top_left.y
  end

  def crop_params
    crop_params = <<-EOL
      #{x_size - 1}x#{y_size-1}+#{face_region.top_left.x + 1}+#{face_region.top_left.y + 1}
    EOL
  end
end
