class Brewery < Sequel::Model
  one_to_many :beers
end
