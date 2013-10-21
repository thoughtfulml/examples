module CrossValidation
  # In conjunction with svm-train this can be used to do a cross validation
  def self.to_data(flush = true)
    out = []
    REDIS.flushall if flush

    %w[pos neg].each do |sent|
      filepath = "./config/rt-polaritydata/rt-polarity.#{sent}"
      sentiment = (sent == 'pos') ? "+1" : "-1"
      parse_file(filepath, sentiment, 5331) if flush

      File.open(filepath, 'rb').each_line do |line|
        vec = [sentiment]
        vec << sparse_vector(line).sort_by(&:first).map {|kv| kv.join(":")}
        out << vec.join(' ')
      end
    end

    File.open('data.txt', 'wb') do |f|
      out.each do |l|
        f.write("#{l}\n")
      end
    end
    out.length
  end

  def self.validation_data
    y_vec = []
    x_mat = []
    rows.times do |row_num|
      next if row_num % 2 == 0
      x_mat << hash_for(row_num)
      y_vec << y_for(row_num)
    end
    [y_vec, x_mat]
  end

  def self.cross_validate!
    -15.step(15,2) do |i|
      total = 0
      errors = 0
      c = 2 ** i
      model = Corpus.train_svm!(c, 2)
      ys, xes = Corpus.validation_data

      ys.each_with_index do |y, i|
        expected = y
        achieved = model.predict(Libsvm::Node.features(xes[i]))
        total += 1
        errors += 1 if achieved != expected
      end

      puts "#{errors.to_f / total} for 2 ** #{i}"
    end
  end

end