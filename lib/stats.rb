require 'matrix'
module Stats
  extend self

  def nearest_neighbor(matrix1)
    descriptors = {}

    Dir['./public/faces/avatar_*.jpg'].each do |f|
      _, desc = FaceFeatures.features(f)
      descriptors[File.basename(f)] = desc
    end

    distances_from = {}

    descriptors.each do |k,v|
      distances_from[k] = distance_matrix(v, matrix1)
    end

    distances_from
  end

  def distance_matrix(matrix1, matrix2)
    matrix = Matrix.build(matrix1.length, matrix2.length) do |row, col|
      euclidean_distance(matrix1[row], matrix2[col])
    end

    # find the closest match even if it's been seen befor
    matrix.row_vectors.map(&:min).inject(&:+)
  end

  def euclidean_distance(vec1, vec2)
    raise 'Error' unless vec1.length == vec2.length

    sum_sq = 0.0

    vec1.each_with_index do |v, i|
      sum_sq += (v - vec2[i]) ** 2
    end

    Math::sqrt(sum_sq)
  end
end