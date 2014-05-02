class CorpusParser
  NULL_CHARACTER = "\0"
  POS_SPLITTER = "/"
  STOP = " "

  def initialize(ngram: 3)
    @ngram = ngram
  end

  def parse(string)
    ngrams = @ngram.times.map { {NULL_CHARACTER => NULL_CHARACTER} }

    word = ''
    pos = ''

    parse_word = true

    string.each_char do |char|
      if char == "\t"
        next
      elsif char == POS_SPLITTER
        parse_word = false
      elsif char == STOP
        ngrams.shift
        ngrams << {word => pos}

        @ngram.times do |i|
          yield ngrams[i..-1]
        end

        parse_word = true
        word = ''
        pos = ''
      elsif parse_word
        word += char
      else
        pos += char
      end
    end
  end
end
