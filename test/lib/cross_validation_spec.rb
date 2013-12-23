require_relative '../spec_helper'
if ENV['CROSS_VALIDATE'] == 't'
  describe 'Cross Validation' do
    def self.folds
      [
        './test/fixtures/fold1.label',
        './test/fixtures/fold2.label'
      ]
    end

    def self.test_order
      :alpha
    end

    folds.each do |fold|
      other_fold = folds.find {|f| f != fold }
      (1..5).each do |gram|
        it "validates #{fold} against #{other_fold} with a #{gram}-Gram model" do

          cache_path = "./test/fixtures/cached/#{File.basename(fold, '.label')}_#{gram}.yml"
          trained_spam = nil
          if File.exists?(cache_path)
            trained_spam = SpamTrainer.from_file(cache_path)
          else
            trained_spam = SpamTrainer.new(fold, gram)
            puts "Training"
            trained_spam.train!
            puts "Done training saving"
            trained_spam.to_file(cache_path)
          end

          correct = 0
          errors = 0

          confidence = 0.0
          File.open(other_fold, 'r').each_line do |line|
            label, file = line.split(/\s+/)
            e = Email.new(File.join('./data/TRAINING', file))

            classification = trained_spam.classify(e)
            confidence += classification.score

            if classification.guess == 'spam' && classification.guess != SpamTrainer::label_to_name(label)
              errors += 1
            else
              correct += 1
            end
          end

          message = <<-EOL
          Error Rate: #{errors / (errors + correct).to_f}.
          Avg Confidence: #{confidence / (errors + correct)}.
          Perplexity: #{trained_spam.perplexity}
          Gram: #{gram}
          EOL
          skip(message)
        end
      end
    end
  end
end