require 'spec_helper'
describe "Cross Validation" do
  let(:files) { Dir['./data/brown/c***'] }
  FOLDS = 10

  FOLDS.times do |i|
    let(:validation_indexes) do
      splits = files.length / FOLDS
      ((i * splits)..((i + 1) * splits)).to_a
    end

    let(:training_indexes) do
      files.length.times.to_a - validation_indexes
    end

    let(:validation_data) do
      files.values_at(*validation_indexes)
    end

    it "cross validates with a low error for fold #{i}" do
      pos_tagger = POSTagger.new(files.values_at(*training_indexes), true)
      misses = 0
      successes = 0

      validation_data.each do |vf|
        File.read(vf).each_line do |l|
          if l =~ /\A\s+\z/
            next
          else
            words = []
            parts_of_speech = ['START']
            l.strip.split(/\s+/).each do |ppp|
              z = ppp.split('/')
              words << z.first
              parts_of_speech << z.last
            end

            tag_seq = pos_tagger.viterbi(words.join(' '))
            misses += tag_seq.zip(parts_of_speech).count {|k,v| k != v }
            successes += tag_seq.zip(parts_of_speech).count {|k,v| k == v }
          end
        end
        puts Rational(misses, successes + misses).to_f
      end
      skip("Error rate was #{misses / (successes + misses).to_f}")
    end
  end
end
