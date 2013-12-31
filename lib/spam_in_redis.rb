module SpamInRedis
  def setup!(training_files)
    training_files.each do |tf|
      redis.hset('totals', tf.first, 0)
    end

    redis.hset('totals', '_all', 0)
  end

  def totals
    redis.hgetall('totals')
  end

  def get(cat, token)
    redis.hget(cat, token).to_i
  end

  def redis
    @redis ||= Redis::Namespace.new(SecureRandom.hex)
  end

  def total_for(category)
    redis.hget('totals', category).to_i
  end

  def categories
    redis.hkeys('totals') - ['_all']
  end

  def write(category, file)
    email = Email.new(file)

    logger.debug("#{category} #{file}")
    Tokenizer.unique_tokenizer(email.blob) do |token|
      redis.hincrby(category, token, 1)
      redis.hincrby('totals', '_all', 1)
      redis.hincrby('totals', category, 1)
    end
  end

end