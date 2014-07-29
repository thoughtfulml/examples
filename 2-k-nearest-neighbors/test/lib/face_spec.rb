require_relative '../spec_helper'
require 'matrix'

describe Face do
  let(:avatar_path) { './test/fixtures/avatar.jpg' }

  it 'writes an annotated image' do
    @face = Face.new(avatar_path)

    file = @face.annotated_image_path

    actual_md5 = Digest::MD5.hexdigest(File.read(file))
    expected_md5 = Digest::MD5.hexdigest(File.read(avatar_path))
  end

  it 'has the same descriptors for the exact same face' do
    @face_descriptors = Face.new(avatar_path).descriptors
    @face2_descriptors = Face.new(avatar_path).descriptors

    @face_descriptors.sort_by! { |row| Vector[*row].magnitude }
    @face2_descriptors.sort_by! { |row| Vector[*row].magnitude }

    @face_descriptors.zip(@face2_descriptors).each do |f1, f2|
      assert (0.99..1.01).include?(cosine_similarity(f1, f2)),
        "Face descriptors don't match"
    end
  end

  it 'has the same keypoints for the exact same face' do
    @face = Face.new(avatar_path)
    @face2 = Face.new(avatar_path)

    # This is purely because Ruby's implementation of OpenCV doesn't
    # Have a representation of == for SurfPoints :(
    @face.keypoints.each_with_index do |kp, i|
      f1 = Vector[kp.pt.x, kp.pt.y]
      f2 = Vector[@face2.keypoints[i].pt.x, @face2.keypoints[i].pt.y]

      assert (0.99..1.01).include?(cosine_similarity(f1,f2)),
        "Face keypoints do not match"
    end
  end
end
