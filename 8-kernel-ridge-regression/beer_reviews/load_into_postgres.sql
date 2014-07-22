create table beer_reviews(
	brewery_id float8
  , brewery_name varchar
  , beer_name varchar
  , beer_style vharchar
  , beer_abv float8
  , beer_beerid float8
  , review_time float8
  , review_overall float8
  , review_aroma float8
  , review_appearance float8
  , review_profilename varchar
  , review_palate float8
  , review_taste float8
);

\COPY beer_reviews FROM 'beer_reviews.csv' CSV HEADER