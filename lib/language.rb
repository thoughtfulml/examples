class Language
  PUNCTUATION = %w[! ~ . @ # $ % ^ & * ( ) _ + ' ? [ ] “ ” ‘ ’ — < > » « › ‹ – „ /]
  SPACES = [" ", "\u00A0"]
  def initialize(text_file, name)
    @name = name
    @text_file = text_file
  end
  
  def frequency_for(character)
    frequencies.fetch(character, 0)
  end
  
  private
  def frequencies
    @frequencies ||= calculate_frequencies(@text_file)
  end
  
  def calculate_frequencies(text_file)
    hash = Hash.new(0)
    File.open(text_file, 'r').each_char do |char|
      if SPACES.include?(char) || PUNCTUATION.include?(char)
        # Do not capture 
      else
        hash[char.downcase] += 1
      end
    end
    hash
  end
end