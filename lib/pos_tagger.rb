require 'set'

class POSTagger
  def initialize(files_to_parse =  [])
    @corpus_parser = CorpusParser.new
    @redis = Redis.new
    @data_files = files_to_parse
    @trained = false

  end

  def train!
    unless @trained
      @tags = Set.new(["START"])
      @tag_combos = Hash.new(0)
      @tag_frequencies = Hash.new(0)
      @word_tag_combos = Hash.new(0)

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

  # Maximum liklihood estimate
  # count(previous_tag, current_tag) / count(previous_tag)
  def tag_probability(previous_tag, current_tag)
    denom = @tag_frequencies[previous_tag]

    if denom.zero?
      0
    else
      Rational(@tag_combos["#{previous_tag}/#{current_tag}"], denom)
    end
  end

  # Maximum Liklihood estimate
  # count (word and tag) / count(tag)
  def word_tag_probability(word, tag)
    denom = @tag_frequencies[tag]

    if denom.zero?
      0
    else
      Rational(@word_tag_combos["#{word}/#{tag}"], denom)
    end
  end

  def probability_of_word_tag(word_sequence, tag_sequence)
    raise 'The word and tags must be the same length!' if word_sequence.length != tag_sequence.length

    # word_sequence %w[START I want to race .]
    # Tag sequence %w[START PRO V TO V .]

    length = word_sequence.length

    probability = Rational(1,1)

    (1...length).each do |i|
      probability *= tag_probability(tag_sequence[i - 1], tag_sequence[i]) * word_tag_probability(word_sequence[i], tag_sequence[i])
    end

    probability
  end

  def write(ngram)
    if ngram.first.tag == 'START'
      @tag_frequencies['START'] += 1
      @word_tag_combos['START/START'] += 1
    end

    @tags << ngram.last.tag

    @tag_frequencies[ngram.last.tag] += 1
    @word_tag_combos[[ngram.last.word, ngram.last.tag].join("/")] += 1
    @tag_combos[[ngram.first.tag, ngram.last.tag].join("/")] += 1
  end

  def viterbi(sentence)
    parts = sentence.split(/\s+/)

    optimal_sequence = [{}]
    backpointers = [{}]

    @tags.each do |tag|
      if tag == 'START'
        next
      else
        optimal_sequence.first[tag] = tag_probability("START", tag) * word_tag_probability(parts.first, tag)
        backpointers.first[tag] = "START"
      end
    end

    parts[1..-1].each do |part|
      viterbi = {}
      backpointer = {}
      prev_viterbi = optimal_sequence.last

      @tags.each do |tag|
        next if tag == 'START'

        best_previous = prev_viterbi.max_by do |prev_tag, probability|
          probability * tag_probability(prev_tag, tag) * word_tag_probability(part, tag)
        end

        best_tag = best_previous.first

        viterbi[tag] = prev_viterbi[best_tag] * tag_probability(best_tag, tag) * word_tag_probability(part, tag)

        backpointer[tag] = best_tag
      end

      optimal_sequence << viterbi
      backpointers << backpointer
    end

    current_tag = optimal_sequence.last.max_by {|k,v| v }.first
    ending = [current_tag]

    backpointers.reverse.map do |bp|
      current_tag = bp[current_tag]
    end.reverse + ending
  end
end
