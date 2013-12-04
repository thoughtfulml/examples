class Face
  include OpenCV
  MIN_HESSIAN = 600

  attr_reader :filepath

  def initialize(filepath)
    @filepath = filepath
  end

  def descriptors
    @descriptors ||= features.last
  end

  def keypoints
    @keypoints ||= features.first
  end

  def write_annotated_image!
    rgb = CvMat.load(@filepath, CV_LOAD_IMAGE_COLOR)
    kp, desc = features

    kp.each do |r|
      center = CvPoint.new(r.pt.x, r.pt.y)
      color = CvColor::Yellow
      radius = r.size * (1.2/9.0) * 2
      rgb.circle! center, radius, :color => color
    end

    extracted_features = "extracted_" + File.basename(@filepath)
    rgb.save_image('/Users/matthewkirk/git/face_query/public/faces/' + extracted_features)

    './public/faces/' + extracted_features
  end

  private
  def features
    image = CvMat.load(@filepath, CV_LOAD_IMAGE_GRAYSCALE)
    param = CvSURFParams.new(MIN_HESSIAN)
    @keypoints, @descriptors = image.extract_surf(param)
  end
end