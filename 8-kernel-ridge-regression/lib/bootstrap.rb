DB = Sequel.connect('postgres://localhost/beer_reviews')

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

DB.run <<-SQL
  CREATE TEMPORARY TABLE beer_reviews (
  brewery_id int
  , brewery_name varchar
  , review_time float8
  , review_overall float8
  , review_aroma float8
  , review_appearance float8
  , review_profilename varchar
  , beer_style varchar
  , review_palate float8
  , review_taste float8
  , beer_name varchar
  , beer_abv float8
  , beer_beerid float8
  )
SQL

DB.run <<-SQL
  \COPY beer_reviews FROM 'beer_reviews.csv' CSV HEADER;
SQL

DB.run <<-SQL
  INSERT INTO breweries (name)
  SELECT DISTINCT(brewery_name) FROM beer_reviews;
SQL

DB.run <<-SQL
  INSERT INTO beers (name, style, abv, brewery_id)
  SELECT beer_name, beer_style, beer_abv, MAX(breweries.id)
  FROM beer_reviews
  JOIN breweries ON beer_reviews.brewery_name = breweries.name
  GROUP BY 1,2,3;
SQL

DB.run <<-SQL
  INSERT INTO reviewers (name)
  SELECT DISTINCT(review_profilename) FROM beer_reviews;
SQL

DB.run <<-SQL
  INSERT INTO reviews (reviewer_id, beer_id, overall, aroma, appearance, palate, taste)
  SELECT r.id, b.id, review_overall, review_aroma, review_appearance, review_palate, review_taste
  FROM beer_reviews br
  JOIN beers b ON b.name = br.beer_name AND b.abv = br.beer_abv AND b.style = br.beer_style
  JOIN reviewers r ON r.name = br.review_profilename;
SQL

DB.run <<-SQL
  INSERT INTO beer_styles (name)
  SELECT DISTINCT(style) FROM beers;
SQL

DB.run <<-SQL
  UPDATE beers b
  SET beer_style_id = bs.id
  FROM beer_styles bs
  WHERE bs.name = b.style;
SQL
