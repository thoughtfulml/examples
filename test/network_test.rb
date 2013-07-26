require 'test/unit'

class NetworkTest < Test::Unit::TestCase
  def setup
    @network = Network.new(26, 12, 6)
    @fat_network = Network.new(200, 50, 50, 3)
  end
  
  def test_output_layer
    assert_equal 6, @network.outputs.length
    assert_equal 3, @fat_network.outputs.length
  end
  
  def test_input_layer
    assert_equal 26, @network.inputs.length
    assert_equal 200, @fat_network.inputs.length
  end
  
  def test_hidden_layer_size
    assert_equal 12, @network.hidden_neurons
    assert_equal 100, @fat_network.hidden_neurons
  end
  
  def test_to_s
    assert_equal '<Network: 26-12-6>', @network.to_s
    assert_equal '<Network: 200-50-50-3>', @fat_network.to_s
  end
end