require 'spec_helper'

describe Reviewer do
  let(:reviewer) { Reviewer.find(:id => 3) }

  it 'calculates a preference for a user correctly' do
    pref = reviewer.preference

    reviewed_styles = reviewer.reviews.map {|r| r.beer.beer_style_id }

    pref.each_with_index do |r,i|
      if reviewed_styles.include?(i + 1)
        r.wont_equal 0
      else
        r.must_equal 0
      end
    end
  end

  it 'gives the highest rated beer_style the highest constant' do
    pref = reviewer.preference

    most_liked = pref.index(pref.max) + 1

    least_liked = pref.index(pref.select(&:nonzero?).min) + 1

    reviews = {}
    reviewer.reviews.each do |r|
      reviews[r.beer.beer_style_id] ||= []
      reviews[r.beer.beer_style_id] <<  r.overall
    end

    review_ratings = Hash[reviews.map {|k,v| 
      [k, v.inject(&:+) / v.length.to_f] 
    }]

    assert review_ratings.fetch(most_liked) > review_ratings.fetch(least_liked)

    best_fit = review_ratings.max_by(&:last)
    worst_fit = review_ratings.min_by(&:last)

    most_liked = review_ratings[most_liked]
    least_liked = review_ratings[least_liked]

    assert best_fit.first == most_liked || best_fit.last == most_liked
    assert worst_fit.first == least_liked || worst_fit.last == least_liked 
  end
end
