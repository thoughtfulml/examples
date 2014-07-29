class Review < Sequel::Model
  many_to_one :reviewer
end
