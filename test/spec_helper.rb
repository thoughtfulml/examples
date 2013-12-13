require 'simplecov'
SimpleCov.command_name "MiniTest #{rand(100000)}"
SimpleCov.start

require 'minitest/autorun'
require 'minitest/pride'
require 'bundler'
require 'phashion'
Bundler.require

require File.expand_path('../../lib/image.rb', __FILE__)
require File.expand_path('../../lib/face.rb', __FILE__)
require File.expand_path('../../lib/neighborhood.rb', __FILE__)
