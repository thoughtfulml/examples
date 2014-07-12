require_relative '../spec_helper'

if ENV['CROSS_VALIDATE'] == 't'
  describe 'Cross Validation' do
    LOGGER = Logger.new(STDOUT, :debug)

    def self.test_order
      :alpha
    end

    def self.label_to_training_data(fold_file)
      training_data = []
      st = SpamTrainer.new([])

      File.open(fold_file, 'rb').each_line do |line|
        label, file = line.split(/\s+/)
        st.write(label, file)
      end

      st
    end

    def self.parse_emails(keyfile)
      emails = []
      puts "Parsing emails for #{keyfile}"
      File.open(keyfile, 'rb').each_line do |line|
        label, file = line.split(/\s+/)
        emails << Email.new(filepath, label)
      end
      puts "Done parsing emails for #{keyfile}"
      emails
    end

    def self.validate(trainer, set_of_emails)
      correct = 0
      false_positives = 0.0
      false_negatives = 0.0
      confidence = 0.0

      set_of_emails.each do |email|
        classification = trainer.classify(email)
        confidence += classification.score
        if classification.guess == 'spam' && email.category == 'ham'
          false_positives += 1
        elsif classification.guess == 'ham' && email.category == 'spam'
          false_negatives += 1
        else
          correct += 1
        end
      end

      message = <<-EOL
      False Positive Rate (Bad): #{false_positives / (false_positives + false_negatives + correct)}
      False Negative Rate (not so bad): #{false_negatives / (false_positives + false_negatives + correct)}
      Error Rate: #{(false_positives + false_negatives) / (false_positives + false_negatives + correct)}
      EOL
      message
    end

    describe "Fold1 unigram model" do
      let(:trainer) { self.class.label_to_training_data('./test/fixtures/fold1.label') }
      let(:emails) { self.class.parse_emails('./test/fixtures/fold2.label') }

      it "validates fold1 against fold2 with a unigram model" do
        skip(self.class.validate(trainer, emails))
      end
    end

    describe "Fold2 unigram model" do
      let(:trainer) { self.class.label_to_training_data('./test/fixtures/fold2.label') }
      let(:emails) { self.class.parse_emails('./test/fixtures/fold1.label') }

      it "validates fold2 against fold1 with a unigram model" do
        skip(self.class.validate(trainer, emails))
      end
    end
  end
end