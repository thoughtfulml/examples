require 'base64'
class Image
  HAAR_FILEPATH = './data/haarcascade_frontalface_alt.xml'
  FACE_DETECTOR = OpenCV::CvHaarClassifierCascade::load(HAAR_FILEPATH)

  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
    @face_found = false
  end

  def self.write(filepath, &block)
    if File.exists?(filepath)
    else
      block.call
    end
    filepath
  end

  def self.from_base64(base64)
    filepath = File.join("./public/faces", Digest::MD5.hexdigest(base64)) + ".jpg"

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
    outfile = File.join(".//public/faces", "avatar_" + File.basename(@filepath))
    self.class.write(outfile) do

      region = face_region
      top_left = region.top_left
      bottom_right = region.bottom_right

      x_size = bottom_right.x - top_left.x
      y_size = bottom_right.y - top_left.y

      crop_params = "#{x_size - 1}x#{y_size-1}+#{top_left.x + 1}+#{top_left.y + 1}"
      image = MiniMagick::Image.open(@filepath)
      image.crop crop_params
      image.write(outfile)
    end

    Face.new("./public/faces/" + File.basename(outfile))
  end
end