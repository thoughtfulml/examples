require_relative '../spec_helper'
File.open("report.txt", "wb") {|f| f.write("") }
if ENV['CROSS_VALIDATE'] == 't'
  describe 'Cross Validation' do
    LOGGER = Logger.new(STDOUT, :debug)

    def self.test_order
      :alpha
    end

    def self.label_to_training_data(fold_file, n = 1)
      training_data = []
      st = SpamTrainer.new([], n)

      data = File.read(fold_file).split("\n")

      data.each do |line|
        label, file = line.split(/\s+/)
        filepath = File.join("./data/TRAINING", file)
        klass = (label == '1') ? 'ham' : 'spam'
        st.write(klass, filepath)
      end

      st
    end

    def self.parse_emails(keyfile)
      emails = []
      puts "Parsing emails for #{keyfile}"
      File.open(keyfile, 'rb').each_line do |line|
        label, file = line.chomp.split(/\s+/)
        filepath = File.join("./data/TRAINING", file)
        klass = (label == '1') ? 'ham' : 'spam'
        emails << Email.new(filepath, klass)
        LOGGER.debug("#{filepath} finished")
      end
      puts "Done parsing emails for #{keyfile}"
      emails
    end

    def self.validate(trainer, set_of_emails)
      correct = 0
      errors = 0
      confidence = 0.0

      set_of_emails.each do |email|
        classification = trainer.classify(email)
        confidence += classification.score

        if classification.guess == 'spam' && email.category == 'ham'
          errors += 1
        else
          correct += 1
        end
      end

      message = <<-EOL
      Error Rate: #{errors / (errors + correct).to_f}.
      Avg Confidence: #{confidence / (errors + correct)}.
      Perplexity: #{trainer.perplexity}
      Gram: #{trainer.n}
      EOL
      message
    end

    describe "Fold1 unigram model" do
      let(:trainer) { self.class.label_to_training_data('./test/fixtures/fold1.label', 1) }
      let(:emails) { self.class.parse_emails('./test/fixtures/fold2.label') }

      it "validates fold1 against fold2 with a unigram model" do
        skip(self.class.validate(trainer, emails))
      end
    end

    describe "Fold2 unigram model" do
      let(:trainer) { self.class.label_to_training_data('./test/fixtures/fold2.label', 1) }
      let(:emails) { self.class.parse_emails('./test/fixtures/fold1.label') }

      it "validates fold2 against fold1 with a unigram model" do
        skip(self.class.validate(trainer, emails))
      end
    end
  end
end