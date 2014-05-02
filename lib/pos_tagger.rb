class POSTagger
  def initialize(files_to_parse =  [], ngrams = 2)
    @corpus_parser = CorpusParser.new(ngram: ngrams)
    @redis = Redis.new
    @data_files = files_to_parse
    @trained = false
  end

  def train!
    unless @trained
      @data_files.each do |df|
        File.foreach(df) do |line|
          @corpus_parser.parse(line) do |ngram|
            write(ngram)
          end
        end
      end
      @trained = true
    end
  end

  def tag_probability(previous_tag, current_tag)
     
  end

  def word_tag_probability(word, tag)
    num = @redis.hget("WORD/POS", "#{word}/#{tag}").to_i
    denom = @redis.get("word_total").to_i

    if denom.zero?
      0
    else
      Rational(num, denom)
    end
  end

=begin
  def vertibi(sentence)
    pos_tags = @redis.get("tags")
    parts = sentence.split(/\s+/)

    part_length = parts.length

    vertibi = []
    backpointer = []


    first_vertibi = {}
    first_backpointer = {}

    pos_tags.each do |tag|
      if tag == "\0"
        next
      else
        first_vertibi[tag] = conditional_prob["\0"].prob(tag) * cpd_tagwords[tag].prob (parts[0])
        first_backpointer[tag] = "\0"
      end
    end

    vertibi << first_vertibi
    backpointer << first_backpointer

    parts[1..-1].each do |part|
      this_vertibi = {}
      this_backpointer = {}
      prev_vertibi = vertibi.last

      pos_tags.each do |tag|
        if tag == "\0"
          next
        else
          best_previous = nil
          best_prob = 0.0

          prev_vertibi.keys.each do |prev_key|
            prob = prev_vertibi[prev_key] * cpd_tags[prev_key].prob(tag) * cpd_tagwords[tag].prob(part)
            if prob >= best_prob
              best_previous = prev_key
              best_prob = prob
            end
          end
          this_vertibi[tag] = prev_vertibi[best_previous] * cpd_tags[best_previous].prob(tag) * cpd_tagwords[tag].prob(part)
          this_backpointer[tag] = best_previous
        end
      end
      vertibi << this_vertibi
      backpointer << this_backpointer
    end

  end
=end

  def write(ngram)
    @redis.hincrby('POS', ngram.map(&:values).flatten.join(":"), 1)
    @redis.hincrby('WORD', ngram.map(&:keys).flatten.join(":"), 1)

    if ngram.last.to_a[0][1] == '.'
      ngram.each do |gram|
        gg = gram.to_a.first
        @redis.hincrby("WORD/POS", "#{gg[0]}/#{gg[1]}", 1)
        @redis.incr('word_total')
      end
    else
      nn = ngram.first.to_a[0]
      @redis.hincrby('WORD/POS', "#{nn.first}/#{nn.last}", 1) 
      @redis.incr('word_total')
    end

    @redis.incr('total_words')
    @redis.incr(ngram.join(":"))
  end
end
