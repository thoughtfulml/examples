require 'json'
class Neighborhood
  def initialize(files)
    @ids = {}
    @files = files
    setup!
  end

  def attributes
    if @attributes.nil?
     attributes = {}
      @files.each do |file|
        att_name = File.join(File.dirname(file), 'attributes.json')

        attributes[att_name.split("/")[-2]] = JSON.parse(File.read(att_name))
      end
      @attributes = attributes
    else
      @attributes
    end
  end

  def self.face_class(filename, subkeys)
    dir = File.dirname(filename)
    base = File.basename(filename, '.png')

    attributes_path = File.expand_path('attributes.json', dir)
    json = JSON.parse(File.read(attributes_path))

    h = nil

    if json.is_a?(Array)
      h = json.find do |hh|
        hh.fetch('ids').include?(base.to_i)
      end or
      raise "Cannot find #{base.to_i} inside of #{json} for file #{filename}"
    else
      h = json
    end

    h.select {|k,v| subkeys.include?(k) }
  end

  def attributes_guess(file, k = 4)
    ids = nearest_feature_ids(file, k)

    votes = {
      'glasses' => {false => 0, true => 0},
      'facial_hair' => {false => 0, true => 0}
    }

    ids.each do |id|
      resp = self.class.face_class(@ids[id], %w[glasses facial_hair])

      resp.each do |k,v|
        votes[k][v] += 1
      end
    end

    votes
  end

  def file_from_id(id)
    @ids.fetch(id)
  end

  def nearest_feature_ids(file, k)
    desc = Face.new(file).descriptors

    ids = []

    desc.each do |d|
      ids.concat(@kd_tree.find_nearest(d, k).map(&:last))
    end

    ids.uniq
  end

  private
  def setup!
    counter = 0
    kdtree_hash = {}

    @files.each do |f|
      desc = Face.new(f).descriptors
      desc.each do |d|
        @ids[counter] = f
        kdtree_hash[counter] = d
        counter += 1
      end
    end

    @kd_tree = Containers::KDTree.new(kdtree_hash)
  end
end
