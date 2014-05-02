require 'spec_helper'

describe CorpusParser do
  let (:stream) { '	Several/ap defendants/nns' } 

  it 'will parse a brown corpus line using the standard / notation' do
    cp = CorpusParser.new(ngram: 3)

    null = {"\0" => "\0"}
    several = {"Several" => "ap"}
    defendants = {"defendants" => "nns"}
    expectations = [
      [null, null, several],
      [null, several],
      [several],
      [null, several, defendants],
      [several, defendants],
      [defendants]
    ]

    cp.parse(stream) do |ngram|
      ngram.must_equal expectations.shift
    end
  end
end
