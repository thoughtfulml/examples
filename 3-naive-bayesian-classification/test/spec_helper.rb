require 'tempfile'

require 'minitest/autorun'
require 'minitest/pride'
require 'bundler'
require 'logger'
Bundler.require

require File.expand_path('../../lib/email.rb', __FILE__)
require File.expand_path('../../lib/tokenizer.rb', __FILE__)
require File.expand_path('../../lib/spam_trainer.rb', __FILE__)
