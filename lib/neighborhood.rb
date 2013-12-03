require_relative 'face'

class Neighborhood
  def initialize(files)
    @ids = {}
    counter = 0
    kdtree_hash = {}

    files.each do |f|
      desc = Face.new(f).features
      desc.each do |d|
        @ids[counter] = f
        kdtree_hash[counter] = d
        counter += 1
      end
    end

    @kd_tree = Containers::KDTree.new(kdtree_hash)
  end

  def attributes
    @attributes ||= Hash[Dir['./public/att_faces/**/attributes.json'].map do |att|
      [att.split("/")[-2], JSON.parse(File.read(att))]
    end]
  end

  def nearest(file, k)
    desc = Face.new(file).features

    ids = []

    desc.each do |d|
      ids.concat(@kd_tree.find_nearest(d, k).map(&:last))
    end

    ids
  end

  def most_voted_for(file, k)
    ids = nearest(file, k)
    glasses_true = 0
    glasses_false = 0

    ids.each do |id|
      puts id
      if attributes[@ids.fetch(id).split("/")[-2]].fetch('glasses')
        glasses_true += 1
      else
        glasses_false += 1
      end
    end

    {
      :glasses_true => glasses_true,
      :glasses_False => glasses_false
    }

  end

  # def nearest(matrix, k)
  #     descriptors = {}
  #     distances_from = {}
  #
  #     @files.each do |f|
  #       _, desc = Face.new(f).features
  #
  #       key = File.basename(f)
  #       descriptors[key] = desc
  #       distances_from[key] = distance(desc, matrix)
  #     end
  #
  #     distances_from.sort_by(&:last).first(k)
  #   end
  #
  #   def distance(matrix1, matrix2)
  #     matrix = Matrix.build(matrix1.length, matrix2.length) do |row, col|
  #       euclidean_distance(matrix1[row], matrix2[col])
  #     end
  #
  #     # find the closest match even if it's been seen befor
  #     matrix.row_vectors.map(&:min).inject(&:+)
  #   end
  #
  #   def euclidean_distance(vec1, vec2)
  #     raise 'Error' unless vec1.length == vec2.length
  #
  #     sum_sq = 0.0
  #
  #     vec1.each_with_index do |v, i|
  #       sum_sq += (v - vec2[i]) ** 2
  #     end
  #
  #     Math::sqrt(sum_sq)
  #   end
end