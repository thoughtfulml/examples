require 'bundler'
Bundler.require

DB = Sequel.connect('postgres://localhost/beer_reviews')

autoload :UserPreference, 'models/user_preference'
autoload :Reviewer, 'models/reviewer'
autoload :Brewery, 'models/brewery'
autoload :Beer, 'models/beer'
autoload :BeerStyle, 'models/beer_style'
autoload :Review, 'models/review'
