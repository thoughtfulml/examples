require 'matrix'
require 'libsvm'

class Corpus
  def self.parse_file(filepath, sentiment, lines)
    pbar = ProgressBar.create(:title => "#{File.basename(filepath)}", :total => lines)

    File.open(filepath, 'rb').each_line do |line|
      parse_line(line, sentiment)
      pbar.increment
    end

    REDIS.set("sentiment_analyzer:#{File.basename(filepath)}:processed", 1)
  end

  # Creates a vector that is just indices pointing to 1's
  def self.sparse_vector(string)
    sparse_vector = {}
    string.gsub(/[\.\?\!]/, '').downcase.split(/\s+/).each do |word|
      index = fetch(word)
      next if index.nil?
      sparse_vector[index.to_i] = 1
    end
    sparse_vector
  end

  # Mainly wrap the sparse_vector in something
  def self.vector(string)
    Libsvm::Node.features(sparse_vector(string))
  end

  def self.rows
    REDIS.get("sentiment_lines").to_i - 1
  end

  def self.y_for(row_num)
    REDIS.get("sentiment_line_y_#{row_num}").to_i
  end

  def self.hash_for(row_num)
    xes = Hash.new(0)
    REDIS.smembers("sentiment_line_#{row_num}").map(&:to_i).each do |col_num|
      xes[col_num] = 1
    end
    xes
  end

  def self.train_svm!(c = 2 ** 13, mod = 1)
    columns = REDIS.get("sentiment_analyzer:last_index").to_i - 1

    y_vec = []
    x_mat = []

    pbar = ProgressBar.create(:total => rows)
    rows.times do |row_num|
      next unless row_num % mod == 0
      x_mat << Libsvm::Node.features(hash_for(row_num))
      y_vec << y_for(row_num)
      pbar.increment
    end

    prob = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new
    parameter.cache_size = 100

    parameter.gamma = Rational(1, y_vec.length).to_f
    parameter.eps = 0.0001

    parameter.c = c
    parameter.kernel_type = Libsvm::KernelType::RBF

    prob.set_examples(y_vec, x_mat)
    Libsvm::Model.train(prob, parameter)
  end

  def self.parse_line(line, sentiment)
    index = REDIS.get("sentiment_lines") || 0

    indexes = line.split(/\s+/).map { |word| incr(word) }

    REDIS.set("sentiment_line_y_#{index}", sentiment)
    REDIS.sadd("sentiment_line_#{index}", indexes)

    REDIS.incr("sentiment_lines")
  end

  def self.incr(word)
    index = REDIS.get("sentiment_analyzer:last_index") || 0
    if REDIS.setnx("sentiment_analyzer:#{word}", index)
      REDIS.incr("sentiment_analyzer:last_index")
    end
    index
  end

  def self.fetch(word)
    REDIS.get("sentiment_analyzer:#{word}")
  end
end