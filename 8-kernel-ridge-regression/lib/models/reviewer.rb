class Reviewer < Sequel::Model
  one_to_many :reviews
  one_to_many :user_preferences

  IDENTITY = NMatrix[
    *Array.new(104) { |i|
      Array.new(104) { |j|
        (i == j) ? 1.0 : 0.0
      }
    }
  ]

  def preference
    @max_beer_id = BeerStyle.count
    return [] if reviews.empty?
    rows = []
    overall = []

    context = DB.fetch(<<-SQL)
      SELECT
        AVG(reviews.overall) AS overall
        , beers.beer_style_id AS beer_style_id
      FROM reviews
      JOIN beers ON beers.id = reviews.beer_id
      WHERE reviewer_id = #{self.id}
      GROUP BY beer_style_id;
    SQL

    context.each do |review|
      overall << review.fetch(:overall)
      beers = Array.new(@max_beer_id) { 0 }
      beers[review.fetch(:beer_style_id) - 1] = 1
      rows << beers
    end

    x = NMatrix[*rows]
    shrinkage = 0

    left = nil
    iteration = 6

    xtx = (x.transpose * x).to_f

    left = xtx + shrinkage * IDENTITY

    until MatrixDeterminance.new(left).regular?
      puts "Shrinking iteration #{iteration}"
      shrinkage = (2 ** iteration) * 10e-6
      iteration += 1
      left = xtx + shrinkage * IDENTITY
    end

    (left * x.transpose * NMatrix[overall].transpose).to_a.flatten
  end

  def friend
    skip_these = styles_tasted - [favorite.id]

    someone_else = UserPreference.where(
      'beer_style_id = ? AND beer_style_id NOT IN ? AND reviewer_id != ?',
      favorite.id,
      skip_these,
      self.id
    ).order(:preference).last.reviewer
  end

  def styles_tasted
    reviews.map { |r| r.beer.beer_style_id }.uniq
  end

  def recommend_new_style
    UserPreference.where(
      'beer_style_id NOT IN ? AND reviewer_id = ?',
      styles_tasted,
      friend.id
    ).order(:preference).last.beer_style
  end
end
