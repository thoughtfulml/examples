class EMClusterer
  def initialize(k, data)
    @labels = Array.new(data.row_size) { Array.new(k) { 1.0 / k }}
    @k = k
    @width = data.column_size
    @s = 0.2

    @classes = k.times.map do |cc|
      {
        :indicator => rand_vector,
        :covariance => @s * Matrix.identity(@width)
      }
    end
    @data = data
  end

  def rand_vector
    Vector[*@width.times.map { rand(-1.0..1.0) }]
  end

  def expect
    @classes.each_with_index do |klass, i|
      inv_cov = klass[:covariance].inv
      d = Math::sqrt(klass[:covariance].det)
      @data.row_vectors.each_with_index do |row, j|
        rel = row - klass[:indicator]
        p = d * Math::exp((-0.5 * (Matrix[rel] * inv_cov) * rel).first)
        @labels[j][i] = p
      end
    end

    @labels = @labels.map do |probabilities|
      sum = probabilities.inject(&:+)
      if sum.zero?
        probabilities.map { 1.0 / @k }
      else
        probabilities.map {|p| p / sum.to_f }
      end
    end
  end

  def maximize
    @classes.each_with_index do |klass, i|
      sum = Array.new(@width) { 0 }
      num = 0

      @data.each_with_index do |row, j|
        p = @labels[j][i]

        @width.times do |k|
          sum[k] += p * @data[i,k]
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

      covariance = (1.0/num) * covariance

      @classes[i][0] = mean
      @classes[i][1] = covariance
    end
  end
end

__END__

data = Matrix[
  [1,4],
  [5,2],
  [6,2],
  [7,67],
  [80, 80]
]

data = [
  [1,4],
  [5,2],
  [6,2],
  [7,67],
  [80, 80]
]
