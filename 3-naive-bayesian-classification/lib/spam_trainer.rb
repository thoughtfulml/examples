require 'yaml'
require_relative './store_in_memory'

class SpamTrainer
  Classification = Struct.new(:guess, :score)
  attr_reader :n
  attr_accessor :logger

  include StoreInMemory

  def initialize(training_files)
    setup!(training_files)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN

    @to_train = training_files
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

  def trained?
    @to_train.empty?
  end

  def score(email)
    train!

    raise 'Must implement #blob on given object' unless email.respond_to?(:blob)

    cat_totals = totals

    aggregates = Hash[categories.map do |cat|
      [cat, Rational(cat_totals.fetch(cat).to_i, cat_totals.fetch("_all").to_i)]
    end]

    Tokenizer.unique_tokenizer(email.blob) do |token|
      categories.each do |cat|
        r = Rational(get(cat, token) + 1, cat_totals.fetch(cat).to_i + 1)
        aggregates[cat] *= r
      end
    end

    aggregates
  end

  def normalized_score(email)
    score = score(email)
    sum = score.values.inject(&:+)

    Hash[score.map do |cat, aggregate|
      [cat, (aggregate / sum).to_f]
    end]
  end

  def classify(email)
    score = score(email)
    max_score = 0.0
    max_key = preference.last
    score.each do |k,v|
      if v > max_score
        max_key = k
        max_score = v
      elsif v == max_score && preference.index(k) > preference.index(max_key)
        max_key = k
        max_score = v
      else
        # Do nothing
      end
    end
    throw 'error' if max_key.nil?
    Classification.new(max_key, max_score)
  end

  def inspect
    "<SpamTrainer: @keyfile=#{@keyfile} @doc_count=#{@doc_count}>"
  end
end