require 'opencv'
class Face
  def self.from_base64(base64)
    encoded_data = Base64.decode64(base64)
    filepath = File.join("/Users/matthewkirk/git/face_query/public/faces", SecureRandom.hex) + ".jpg"
    File.open(filepath, 'wb') {|f| f.write(encoded_data)}
    image = MiniMagick::Image.open(filepath)
    image.colorspace 'Gray'
    image.write(filepath)
    detect_face(filepath)
  end

  def self.detect_face(filepath)
    data = './data/haarcascade_frontalface_alt.xml'
    detector = OpenCV::CvHaarClassifierCascade::load(data)
    image = OpenCV::CvMat.load(filepath, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)

    region = detector.detect_objects(image).first

    # detector.detect_objects(image).each do |region|
      color = OpenCV::CvColor::Blue
      image.rectangle! region.top_left, region.bottom_right, :color => color
    # end

    image.save_image(filepath)

    {
      :avatar => extract_avatar(filepath, region),
      :face => "faces/" + File.basename(filepath)
    }
  end

  def self.extract_avatar(filepath, region)
    top_left = region.top_left
    bottom_right = region.bottom_right

    x_size = bottom_right.x - top_left.x
    y_size = bottom_right.y - top_left.y

    crop_params = "#{x_size - 1}x#{y_size-1}+#{top_left.x + 1}+#{top_left.y + 1}"
    image = MiniMagick::Image.open(filepath)

    image.crop crop_params

    outfile = File.join("/Users/matthewkirk/git/face_query/public/faces", "avatar_" + File.basename(filepath))
    image.write(outfile)
    "faces/" + File.basename(outfile)
  end
end