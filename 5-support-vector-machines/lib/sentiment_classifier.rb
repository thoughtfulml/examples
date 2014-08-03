class SentimentClassifier
  def initialize(corpus_set)
    @corpus_set = corpus_set
    @c = 2 ** 7
  end

  def c=(cc)
    @c = cc
    @model = nil
  end

  def words
    @corpus_set.words
  end

  def self.build(files)
    new(CorpusSet.new(files.map do |file|
      mapping = {
        '.pos' => :positive,
        '.neg' => :negative
      }
      Corpus.new(File.open(file, 'rb'), mapping.fetch(File.extname(file)))
    end))
  end

  def present_answer(answer)
    {
      -1.0 => :negative,
      1.0 => :positive
    }.fetch(answer)
  end

  def classify(string)
    if trained?
      prediction = @model.predict(@corpus_set.sparse_vector(string))
      present_answer(prediction)
    else
      @model = model
      classify(string)
    end
  end

  def trained?
    !!@model
  end

  def model
    puts 'starting to get sparse vectors'
    y_vec, x_mat = @corpus_set.to_sparse_vectors

    prob = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new
    parameter.cache_size = 1000

    parameter.gamma = Rational(1, y_vec.length).to_f
    parameter.eps = 0.001

    parameter.c = @c
    parameter.kernel_type = Libsvm::KernelType::LINEAR

    prob.set_examples(y_vec, x_mat)
    Libsvm::Model.train(prob, parameter)
  end
end
