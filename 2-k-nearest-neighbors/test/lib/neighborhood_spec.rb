require_relative '../spec_helper'
require 'benchmark'

describe Neighborhood do
  def measure_x_times(times, &block)
    dist = []

    dist << Benchmark.measure do
      block.call
    end

    dist
  end

  let(:files) { Dir['./public/att_faces/**/*.png'] }

  let(:file_folds) do
    {
      'fold1' => files.each_with_index.select {|f, i| i.even? }.map(&:first),
      'fold2' => files.each_with_index.select {|f, i| i.odd? }.map(&:first)
    }
  end

  let(:neighborhoods) do
    {
      'fold1' => Neighborhood.new(file_folds.fetch('fold1')),
      'fold2' => Neighborhood.new(file_folds.fetch('fold2'))
    }
  end

  if ENV['OPTIMIZE_K'] == 't'
    %w[fold1 fold2].each_with_index do |fold, i|
      other_fold = "fold#{(i + 1) % 2 + 1}"
      it "cross validates #{fold} against #{other_fold}" do
        (1..7).each do |k_exp|
          k = 2 ** k_exp - 1
          errors = 0
          successes = 0

          dist = measure_x_times(2) do
            file_folds.fetch(fold).each do |vf|
              face_class = Neighborhood.face_class(vf, %w[glasses facial_hair])
              actual = neighborhoods.fetch(other_fold).attributes_guess(vf, k)

              face_class.each do |k,v|
                if actual[k][v] > actual[k][!v]
                  successes += 1
                else
                  errors += 1
                end
              end
            end
          end

          error_rate = errors / (errors + successes).to_f

          avg_time = dist.reduce(Rational(0,1)) do |sum, bm| 
            sum += bm.real * Rational(1,2)
          end
          print "#{k}, #{error_rate}, #{avg_time}\n"
        end
      end
    end
  end

  it 'finds the nearest face which is itself' do
    files = ['./test/fixtures/avatar.jpg']
    neighborhood = Neighborhood.new(files)

    descriptor_count = Face.new(files.first).descriptors.length
    attributes = JSON.parse(File.read('./test/fixtures/attributes.json'))

    expectation = {
      'glasses' => {
      attributes.fetch('glasses') => descriptor_count,
      !attributes.fetch('glasses') => 0
    },
      'facial_hair' => {
      attributes.fetch('facial_hair') => descriptor_count,
      !attributes.fetch('facial_hair') => 0
    }
    }

    neighborhood.attributes_guess(files.first).must_equal expectation
  end

  it 'returns attributes from given files' do
    files = ['./test/fixtures/avatar.jpg']

    n = Neighborhood.new(files)

    expected = {
      'fixtures' => JSON.parse(File.read('./test/fixtures/attributes.json'))
    }

    n.attributes.must_equal expected
  end

  it 'finds the nearest id for a given face' do
    files = ['./test/fixtures/avatar.jpg']
    n = Neighborhood.new(files)

    n.nearest_feature_ids(files.first, 1).each do |id|
      n.file_from_id(id).must_equal files.first
    end
  end

  it 'returns the proper face class' do
    file = './public/att_faces/s1/1.png'
    attrs = JSON.parse(File.read('./public/att_faces/s1/attributes.json'))

    expectation = {'glasses' => false, 'facial_hair' => false}

    attributes = %w[glasses facial_hair]
    Neighborhood.face_class(file, attributes).must_equal expectation
  end

  it 'returns the proper face class when there is multiples' do
    file = './public/att_faces/s17/1.png'
    file2 = './public/att_faces/s17/3.png'

    Neighborhood.face_class(file, %w[glasses facial_hair]).
      must_equal({'glasses' => true, 'facial_hair' => true})

    Neighborhood.face_class(file, %w[glasses facial_hair]).
      must_equal({'glasses' => true, 'facial_hair' => true})
  end

end
