require 'ruby-fann'
class Network
  def initialize(languages)
    @languages = languages
    @inputs = @languages.map {|l| l.characters.to_a }.flatten.uniq.sort
    @fann = :not_ran
    @trainer = :not_trained
  end

  def train!
    build_trainer!
    build_standard_fann!
    @fann.train_on_data(@trainer, 1000, 10, 0.005)
  end

  def code(vector)
    return [] if vector.nil?
    @inputs.map do |i|
      vector.fetch(i, 0.0)
    end
  end

  def run(sentence)
    if @trainer == :not_trained || @fann == :not_ran
      raise 'Must train first call method train!'
    else
      vectors, characters = Tokenizer.tokenize(sentence)
      output_vector = @fann.run(code(vectors.first))
      @languages[output_vector.index(output_vector.max)]
    end
  end

  def inspect
    "#<Network>"
  end

  private
  def build_trainer!
    payload = {
      :inputs => [],
      :desired_outputs => []
    }

    @languages.each_with_index do |language, index|
      inputs = []
      desired_outputs = [0] * @languages.length
      desired_outputs[index] = 1

      language.vectors.each do |vector|
        inputs << code(vector)
      end

      payload[:inputs].concat(inputs)

      language.vectors.length.times do
        payload[:desired_outputs] << desired_outputs
      end
    end

    @trainer = RubyFann::TrainData.new(payload)
  end

  def build_standard_fann!
    hidden_neurons = (2 * (@inputs.length + @languages.length)) / 3

    @fann = RubyFann::Standard.new(
      :num_inputs => @inputs.length,
      :hidden_neurons => [ hidden_neurons ],
      :num_outputs => @languages.length
    )

    @fann.set_activation_function_hidden(:elliot)
  end
end