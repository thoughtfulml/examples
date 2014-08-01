class Review < Sequel::Model
  many_to_one :reviewer
  many_to_one :beer
end
