require 'spec_helper'

describe CorpusParser do
  let (:stream) { '	Several/ap defendants/nns ./.' } 

  it 'will parse a brown corpus line using the standard / notation' do
    cp = CorpusParser.new(ngram: 2)

    null = {"START" => "START"}
    several = {"Several" => "ap"}
    defendants = {"defendants" => "nns"}
    period = {"." => "."}

    expectations = [
      [null, several],
      [several, defendants],
      [defendants, period]
    ]

    cp.parse(stream) do |ngram|
      ngram.must_equal expectations.shift
    end

    expectations.length.zero?.must_equal true
  end
end
