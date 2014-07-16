require 'matrix'
class EMClusterer
  attr_reader :partitions, :data, :labels, :classes

  def initialize(k, data)
    @k = k
    @data = data
    setup_cluster!
  end

  def cluster(iterations = 5)
    iterations.times do |i|
      puts "Iteration #{i}"
      expect_maximize
    end
  end

  def good_enough?
    @labels.all? do |probabilities|
      probabilities.max > 0.9
    end
  end

  def expect_maximize
    expect
    maximize
  end

  def setup_cluster!
    @labels = Array.new(@data.row_size) { Array.new(@k) { 1.0 / @k }}

    @width = @data.column_size
    @s = 0.2

    pick_k_random_indices = @data.row_size.times.to_a.shuffle.sample(@k)

    @classes = @k.times.map do |cc|
      {
        :means => @data.row(pick_k_random_indices.shift),
        :covariance => @s * Matrix.identity(@width)
      }
    end
    @partitions = []
  end

  def restart!
    puts "Restarting"
    setup_cluster!
    expect
  end

  def expect
    @classes.each_with_index do |klass, i|
      puts "Expectation for class #{i}"

      inv_cov = if klass[:covariance].regular?
        klass[:covariance].inv
      else
        puts "Applying shrinkage"
        (klass[:covariance] - (0.0001 * Matrix.identity(@width))).inv
      end

      d = Math::sqrt(klass[:covariance].det)

      @data.row_vectors.each_with_index do |row, j|
        rel = row - klass[:means]

        p = d * Math::exp(-0.5 * fast_product(rel, inv_cov))
        @labels[j][i] = p
      end
    end

    @labels = @labels.map.each_with_index do |probabilities, i|
      sum = probabilities.inject(&:+)

      @partitions[i] = probabilities.index(probabilities.max)

      if sum.zero?
        probabilities.map { 1.0 / @k }
      else
        probabilities.map {|p| p / sum.to_f }
      end
    end
  end

  def fast_product(rel, inv_cov)
    sum = 0

    inv_cov.column_count.times do |j|
      local_sum = 0
      (0 ... rel.size).each do |k|
        local_sum += rel[k] * inv_cov[k, j]
      end
      sum += local_sum * rel[j]
    end

    sum
  end

  def maximize
    @classes.each_with_index do |klass, i|
      puts "Maximizing for class #{i}"
      sum = Array.new(@width) { 0 }
      num = 0

      @data.each_with_index do |row, j|
        p = @labels[j][i]

        @width.times do |k|
          sum[k] += p * @data[j,k]
        end

        num += p
      end

      mean = sum.map {|s| s / num }
      covariance = Matrix.zero(@width, @width)

      @data.row_vectors.each_with_index do |row, j|
        p = @labels[j][i]
        rel = row - Vector[*mean]
        covariance += Matrix.build(@width, @width) do |m,n|
          rel[m] * rel[n] * p
        end
      end

      covariance = (1.0 / num) * covariance

      @classes[i][:means] = Vector[*mean]
      @classes[i][:covariance] = covariance
    end
  end

  def to_s
    partitions
  end
end

# data = Matrix[
#   [1,1],
#   [1,2],
#   [1,3],
#   [2,1],
#   [3,1],
#   [3,2],
#   [3,3],
#   [4,1],
#   [5,1],
#   [5,2],
#   [5,3],
#   [6,4],
#   [6,5],
#   [6,6],
#   [6,7],
#   [6,8],
#   [7,4],
#   [7,6],
#   [7,8],
#   [8,4],
#   [8,6],
#   [8,8]
# ]