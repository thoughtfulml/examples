#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('./lib')

require 'krr'

DB.create_table? :beers do
  primary_key :id
  Integer :beer_style_id, :index => true
  Integer :brewery_id, :index => true
  String :name
  Float :abv
end

DB.create_table? :breweries do
  primary_key :id
  String :name
end

DB.create_table? :reviewers do
  primary_key :id
  String :name
end

DB.create_table? :reviews do
  primary_key :id
  Integer :reviewer_id, :index => true
  Integer :beer_id, :index => true
  Float :overall
  Float :aroma
  Float :appearance
  Float :palate
  Float :taste
end

DB.create_table? :beer_styles do
  primary_key :id
  String :name, :index => true
end

require 'csv'
require 'set'

# brewery_id,brewery_name,review_time,review_overall,review_aroma,review_appearance,review_profilename,beer_style,review_palate,review_taste,beer_name,beer_abv,beer_beerid
breweries = {}
reviewers = {}
beer_styles = {}

if !File.exists?('./beer_reviews/beer_reviews.csv')
  system('bzip2 -cd ./beer_reviews/beer_reviews.csv.bz2 > ./beer_reviews/beer_reviews.csv') or die
end

CSV.foreach('./beer_reviews/beer_reviews.csv', :headers => true) do |line|
  if !breweries.has_key?(line[:brewery_name])
    b = Brewery.create(:name => line[:brewery_name])
    breweries[line[:brewery_name]] = b.id
  end

  if !reviewers.has_key?(line[:review_profilename])
    r = Reviewer.create(:name => line[:review_profilename])
    reviewers[line[:review_profilename]] = r.id
  end

  if !beer_styles.has_key?(line[:beer_style])
    bs = BeerStyle.create(:style => line[:beer_style])
    beer_styles[line[:beer_style]] = bs.id
  end

  beer = Beer.create(:beer_style_id => beer_styles[line[:beer_style]], :name => line[:beer_name], :style => line[:beer_style], :abv => line[:beer_abv], :brewery_id => breweries.fetch(line.fetch(:brewery_name)))
  Review.create(:reviewer_id => reviewers.fetch(line.fetch(:reviewer_profilename)), :beer_id => beer.id, :overall => line[:review_overall], :aroma => line[:review_aroma], :appearance => line[:review_appearance], :palate => line[:review_palate], :taste => line[:review_taste])
end
