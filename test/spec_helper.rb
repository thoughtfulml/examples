require 'simplecov'
SimpleCov.command_name "MiniTest #{rand(100000)}"
SimpleCov.start

require 'minitest/autorun'
require 'minitest/pride'

Dir['./lib/*'].each {|_| require _ }
