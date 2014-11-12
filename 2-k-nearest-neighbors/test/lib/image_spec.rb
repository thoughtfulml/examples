require_relative '../spec_helper'

describe Image do
  it 'tries to convert to a face avatar using haar classifier' do
    @image = Image.new('./test/fixtures/raw.jpg')
    @face = @image.to_face

    avatar1 = Phashion::Image.new("./test/fixtures/avatar.jpg")
    avatar2 = Phashion::Image.new(@face.filepath)

    assert avatar1.duplicate?(avatar2)
  end

  it 'loads a file from base64' do
    file = File.read("./test/fixtures/raw.jpg")
    expected_md5 = Digest::MD5.hexdigest(file)
    base64 = Base64.encode64(file)
    @image = Image.from_base64(base64)

    actual_md5 = Digest::MD5.hexdigest(File.read(@image.filepath))
    expected_md5.must_equal actual_md5
  end

  it 'converts a file loaded from base64' do
    file = File.read("./test/fixtures/raw.jpg")
    base64 = Base64.encode64(file)
    @image = Image.from_base64(base64)
    @face = @image.to_face

    avatar1 = Phashion::Image.new("./test/fixtures/avatar.jpg")
    avatar2 = Phashion::Image.new(@face.filepath)

    assert avatar1.duplicate?(avatar2)
  end
end
