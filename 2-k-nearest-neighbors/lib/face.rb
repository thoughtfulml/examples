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

  def annotated_image_path
    dir = File.dirname(@filepath)
    outpath = File.join(dir, 'extracted_' + File.basename(@filepath))

    Image.write(outpath) do
      rgb = CvMat.load(@filepath, CV_LOAD_IMAGE_COLOR)

      keypoints.each do |r|
        center = CvPoint.new(r.pt.x, r.pt.y)
        color = CvColor::Yellow
        radius = r.size * (1.2/9.0) * 2
        rgb.circle! center, radius, :color => color
      end

      rgb.save_image(outpath)
    end
  end

  private
  def features
    image = CvMat.load(@filepath, CV_LOAD_IMAGE_GRAYSCALE)
    param = CvSURFParams.new(MIN_HESSIAN)
    @keypoints, @descriptors = image.extract_surf(param)
  end
end
