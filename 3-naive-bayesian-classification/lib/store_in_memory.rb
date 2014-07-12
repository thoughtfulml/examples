module StoreInMemory
  def setup!(training_files)
    @categories = Set.new

    training_files.each do |tf|
      @categories << tf.first
    end

    @totals = Hash[@categories.map {|c| [c, 0]}]
    @totals.default = 0
    @totals['_all'] = 0

    @training = Hash[@categories.map {|c| [c, Hash.new(0)]}]
  end

  def totals
    @totals
  end

  def get(cat, token)
    @training[cat][token].to_i
  end

  def total_for(category)
    @totals.fetch(category)
  end

  def categories
    @categories
  end

  def write(category, file)
    email = Email.new(file)

    logger.debug("#{category} #{file}")

    @categories << category
    @training[category] ||= Hash.new(0)

    Tokenizer.unique_tokenizer(email.blob) do |token|
      @training[category][token] += 1
      @totals['_all'] += 1
      @totals[category] += 1
    end
  end

end