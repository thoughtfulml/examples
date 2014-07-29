require 'bundler'
Bundler.require

DB = Sequel.connect('postgres://localhost/beer_reviews')

require 'models/user_preference'
require 'models/reviewer'
require 'models/brewery'
require 'models/beer'
require 'models/beer_style'
require 'models/review'
