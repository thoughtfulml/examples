require 'simplecov'
SimpleCov.command_name "MiniTest #{rand(100000)}"
SimpleCov.start

require 'minitest/autorun'
require 'minitest/pride'
require 'bundler'
Bundler.require

require File.expand_path('../../lib/email.rb', __FILE__)
require File.expand_path('../../lib/tokenizer.rb', __FILE__)
require File.expand_path('../../lib/spam_trainer.rb', __FILE__)
