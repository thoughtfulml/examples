require 'minitest/autorun'
require 'minitest/pride'
require 'bundler'
Bundler.require

require File.expand_path('../../lib/image.rb', __FILE__)
require File.expand_path('../../lib/face.rb', __FILE__)
require File.expand_path('../../lib/neighborhood.rb', __FILE__)

def cosine_similarity(array_1, array_2)
  v1 = Vector[*array_1]
  v2 = Vector[*array_2]

  v1.inner_product(v2) / (v1.magnitude * v2.magnitude)
end
