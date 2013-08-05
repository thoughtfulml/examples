module Tokenizer
  extend self
  PUNCTUATION = %w[~ @ # $ % ^ & * ( ) _ + ' [ ] “ ” ‘ ’ — < > » « › ‹ – „ /]
  SPACES = [" ", "\u00A0", "\n"]
  STOP_CHARACTERS = ['.', '?', '!']

  def tokenize(blob)
    raise 'Must implement each_char on blob' unless blob.respond_to?(:each_char)
    vectors = []
    dist = Hash.new(0)

    characters = Set.new
    blob.each_char do |char|
      if STOP_CHARACTERS.include?(char)
        vectors << normalize(dist) unless dist.empty?
        dist = Hash.new(0)
      elsif SPACES.include?(char) || PUNCTUATION.include?(char)

      else
        character = char.downcase.tr("ÅÄÜÖËÏŚŻ", "åäüöëïśź")
        characters << character
        dist[character] += 1
      end
    end
    vectors << normalize(dist) unless dist.empty?

    [vectors, characters]
  end

  def normalize(hash)
    sum = hash.values.inject(&:+)
    Hash[
      hash.map do |k,v|
        [k, Rational(v,  sum)]
      end
    ]
  end
end