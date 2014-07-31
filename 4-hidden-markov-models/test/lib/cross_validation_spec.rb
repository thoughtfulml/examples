require 'spec_helper'

if ENV['CROSS_VALIDATE'] == 't'
  describe "Cross Validation" do
    def files
      Dir['./data/brown/c***']
    end
    #let(:files) { Dir['./data/brown/c***'] }
    # let(:files) { Dir['./data/brown/c***'] }
    FOLDS = 10

    FOLDS.times do |i|
      let(:validation_indexes) do
        splits = files.length / FOLDS
        ((i * splits)..((i + 1) * splits)).to_a
      end

      let(:training_indexes) do
        files.length.times.to_a - validation_indexes
      end

      let(:validation_files) do
        files.select.with_index {|f, i| validation_indexes.include?(i) }
      end

      let(:training_files) do
        files.select.with_index {|f, i| training_indexes.include?(i) }
      end

      it "cross validates with a low error for fold #{i}" do
        pos_tagger = POSTagger.from_filepaths(training_files, true)
        misses = 0
        successes = 0

        validation_files.each do |vf|
          File.open(vf, 'rb').each_line do |l|
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
end
