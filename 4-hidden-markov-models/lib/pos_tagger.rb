require 'set'
require 'benchmark'

class POSTagger
  def initialize(files_to_parse =  [], eager = false)
    @corpus_parser = CorpusParser.new
    @data_files = files_to_parse

    if eager
      train!
    else
      @trained = false
    end
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
      @tag_combos["#{previous_tag}/#{current_tag}"] / denom.to_f
    end
  end

  # Maximum Liklihood estimate
  # count (word and tag) / count(tag)
  def word_tag_probability(word, tag)
    denom = @tag_frequencies[tag]

    if denom.zero?
      0
    else
      @word_tag_combos["#{word}/#{tag}"] / denom.to_f
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

  def pretty_viterbi(sentence)
    viterbi(sentence).map {|tag| TAGS_TO_NAMES.fetch(tag.upcase, tag) }
  end

  def viterbi(sentence)
    parts = sentence.gsub(/[\.\?!]/) {|a| " #{a}" }.split(/\s+/)

    last_viterbi = {}
    backpointers = ["START"]

    @tags.each do |tag|
      if tag == 'START'
        next
      else
        probability =  tag_probability("START", tag) * word_tag_probability(parts.first, tag)
        if probability > 0
          last_viterbi[tag] = probability
        end
      end
    end

    backpointers << (last_viterbi.max_by{|k,v| v} || @tag_frequencies.max_by{|k,v| v}).first

    parts[1..-1].each do |part|
      viterbi = {}
      @tags.each do |tag|
        next if tag == 'START'
        break if last_viterbi.empty?

        best_previous = last_viterbi.max_by do |prev_tag, probability|
          probability * tag_probability(prev_tag, tag) * word_tag_probability(part, tag)
        end

        best_tag = best_previous.first

        probability = last_viterbi[best_tag] * tag_probability(best_tag, tag) * word_tag_probability(part, tag)

        if probability > 0
          viterbi[tag] = probability
        end
      end


      last_viterbi = viterbi
      
      backpointers << (last_viterbi.max_by{|k,v| v} || @tag_frequencies.max_by{|k,v| v }).first
    end
    backpointers
  end
end
