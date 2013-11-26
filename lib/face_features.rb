class FaceFeatures
  include OpenCV

  def self.features(filepath)
    image = CvMat.load(filepath, CV_LOAD_IMAGE_GRAYSCALE)

    min_hessian = 500
    param = CvSURFParams.new(min_hessian)

    image.extract_surf(param)
  end

  def self.extract(avatar)
    avatar = File.expand_path("../../public/#{avatar}", __FILE__)
    rgb = CvMat.load(avatar, CV_LOAD_IMAGE_COLOR)
    kp, desc = features(avatar)

    kp.each do |r|
      center = CvPoint.new(r.pt.x, r.pt.y)
      color = CvColor::Yellow
      radius = r.size * (1.2/9.0) * 2
      rgb.circle! center, radius, :color => color
    end

    extracted_features = "extracted_" + File.basename(avatar)
    rgb.save_image('/Users/matthewkirk/git/face_query/public/faces/' + extracted_features)

    'faces/' + extracted_features
  end
end