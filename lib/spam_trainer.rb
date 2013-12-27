require 'yaml'
class SpamTrainer
  Classification = Struct.new(:guess, :score)
  SmallestDelta = 0.01
  attr_reader :n
  attr_accessor :logger

  def initialize(training_files, n = 1)
    @n = n

    training_files.each do |tf|
      redis.sadd('categories', tf.first)
      redis.hset('totals', tf.first, 0)
    end

    redis.hset('totals', '_all', 0)

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN

    @to_train = training_files
  end

  def redis
    @redis ||= Redis::Namespace.new(SecureRandom.hex)
  end

  def total_for(category)
    redis.hget('totals', category).to_i
  end

  def categories
    redis.smembers('categories')
  end

  def preference
    @preference ||= begin
      categories.sort_by {|cat| total_for(cat) }
    end
  end

  def train!
    @to_train.each do |category, file|
      write(category, file)
    end
    @to_train = []
  end

  def write(category, file)
    email = Email.new(file)
    logger.debug("#{category} #{file}")
    Tokenizer.ngram(email.blob, @n) do |ngram|
      redis.hincrby(category, ngram.join(':'), 1)
      redis.hincrby('totals', '_all', 1)
      redis.hincrby('totals', category, 1)
    end
  end

  def trained?
    @to_train.empty?
  end

  def entropy
    train!
    entropy = 0

    categories.each do |category|
      # Ugh I wish that we could all just use redis 2.8.0

      redis.hgetall(category).each do |token, count|
        prob = Rational(count.to_i, total_for("_all"))
        entropy += prob * Math::log2(prob)
      end
    end
    entropy
  end

  def perplexity
    2 ** -(entropy)
  end

  def score(email)
    train!

    raise 'Must implement #blob on given object' unless email.respond_to?(:blob)

    average_probabilities = Hash.new(0)
    count = 0

    Tokenizer.ngram(email.blob, @n) do |ngram|
      category_probs = {}
      ngram_probs = {}
      parts = {}

      categories.each do |cat|
        category_probs[cat] = Rational(total_for(cat), total_for("_all"))
        ngram_probs[cat] = Rational(redis.hget(cat, ngram.join(':')).to_i + 1, total_for(cat))
        parts[cat] = ngram_probs[cat] * category_probs[cat]
      end

      denom = parts.values.inject(&:+)

      categories.each do |cat|
        before = average_probabilities[cat]
        average_probabilities[cat] = before + Rational((Rational(parts[cat], denom) - before), (count + 1))
      end
    end

    average_probabilities
  end

  def classify(email)
    score = score(email)
    max_score = 0.0
    max_key = nil
    score.each do |k,v|
      if v > max_score
        max_key = k
        max_score = v
      elsif v == max_score && !max_key.nil? && preference.index(k) > preference.index(max_key)
        max_key = k
        max_score = v
      else
        # Do nothing
      end
    end

    Classification.new(max_key, max_score)
  end

  def inspect
    "<SpamTrainer: @keyfile=#{@keyfile} @doc_count=#{@doc_count}>"
  end
end