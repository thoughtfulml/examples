require 'yaml'
class SpamTrainer
  Classification = Struct.new(:guess, :score)
  def initialize(keyfile, n = 3)
    @keyfile = keyfile
    @n = n
    @training = {
      'spam' => Hash.new(0),
      'ham' => Hash.new(0),
    }
    @doc_count = 0
  end

  def self.from_file(file)
    f = YAML::load_file(file)
    st = new(f.fetch(:keyfile))
    st.instance_variable_set("@doc_count", f.fetch(:doc_count))
    st.instance_variable_set("@training", f.fetch(:training))
    st.instance_variable_set("@trained", true)
    st
  end

  def to_file(path)
    File.open(path, 'wb') do |f|
      f.write(YAML::dump({:doc_count => @doc_count, :training => @training, :keyfile => @keyfile}))
    end
  end

  def train!
    current_file = ''
    File.open(@keyfile, 'r').each_line do |line|
      label, file = line.split(' ')
      current_file = file
      spam_or_ham = self.class.label_to_name(label)
      email = Email.new("./data/TRAINING/#{file}")

      Tokenizer.ngram(email.body, @n) do |ngram|
        @training[spam_or_ham][ngram.join(":")] += 1
        @doc_count += 1
      end

      Tokenizer.ngram(email.subject, @n) do |ngram|
        @training[spam_or_ham][ngram.join(":")] += 1
        @doc_count += 1
      end
    end

    @spam_count = @training['spam'].values.inject(&:+)
    @ham_count = @training['ham'].values.inject(&:+)
    puts "Done training"
    @trained = true
  end

  def perplexity
    2 ** (-entropy)
  end

  def entropy
    sum = 0
    @training.each do |cat, data|
      data.each do |ngram, count|
        probability = Rational(count, @doc_count)
        sum += probability * Math::log2(probability)
      end
    end
    sum
  end

  def self.label_to_name(label)
    (label == '1') ? 'ham' : 'spam'
  end

  def score(email)
    raise 'Not Trained' if !@trained

    hams = []
    spams = []
    Tokenizer.ngram([email.body, email.subject].join("\n"), @n) do |ngram|
      p_ham = Rational(@ham_count, @doc_count)
      p_spam = Rational(@spam_count, @doc_count)

      p_ngram_spam = Rational(@training['spam'].fetch(ngram.join(":"), 0) + 1, @spam_count)
      p_ngram_ham = Rational(@training['ham'].fetch(ngram.join(":"),0) + 1, @ham_count)

      p_part = (p_ngram_spam * p_spam)

      p_spam_given_words = (p_part) / (p_part + p_ngram_ham * p_ham).to_f

      spams << p_spam_given_words
      hams << 1 - p_spam_given_words
    end

    {'ham' => hams.inject(&:+) / hams.length, 'spam' => spams.inject(&:+) / spams.length}
  end

  def classify(email)
    Classification.new(*score(email).max_by(&:last))
  end

  def inspect
    "<SpamTrainer: @keyfile=#{@keyfile} @doc_count=#{@doc_count}>"
  end
end