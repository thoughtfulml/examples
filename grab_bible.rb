require 'nokogiri'
require 'open-uri'

url = "http://www.biblegateway.com/passage/"

languages = {
  'English' => {'version' => 'ESV', 'search' => ['Matthew', 'Acts']},
  "Dutch" => {'version' => 'HTB', 'search' => ['Matthe%C3%BCs', 'Handelingen']},
  'Polish' => {'version' => 'SZ-PL', 'search' => ['Ewangelia+według+św.+Mateusza', 'Dzieje+Apostolskie']},
  'German' => {'version' => 'HOF', 'search' => ['Matthaeus', 'Apostelgeschichte']},
  'Finnish' => {'version' => 'R1933', 'search' => ['Matteuksen', 'Teot']},
  'Swedish' => {'version' => 'SVL', 'search' => ['Matteus', 'Apostlagärningarna']},
  'Norwegian' => {'version' => 'DNB1930', 'search' => ['Matteus', 'Apostlenes-gjerninge']}
}

languages.each do |language, search_pattern|
  text = ''

  search_pattern['search'].each_with_index do |search, i|
    1.upto(28).each do |page|
      puts "Querying #{language} #{search} chapter #{page}"
      uri = url + "?search=#{URI.escape(search)}+#{page}&version=#{search_pattern.fetch('version')}"
      puts uri
      doc = Nokogiri::HTML.parse(open(uri))
      doc.css('.passage p').each do |verse|
        text += verse.inner_text.downcase.gsub(/[\d,;:\\\-\"]/,'')
      end
      # end
    end
    File.open("#{language}_#{i}.txt", 'wb') {|f| f.write(text)}
  end
end
