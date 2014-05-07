require 'nokogiri'
require 'open-uri'
require 'csv'

def parse_page(url)
  puts "Parsing #{url}"
  doc = Nokogiri::HTML.parse(open(url))
  headings = doc.xpath("//table/tr/td/center")
  output = {}
  
  headings.each do |heading|
    output[heading.inner_text.strip] = []
  end
  
  (1..10).each do |i|
    list = doc.xpath("//table/tr/td/ol[#{i}]/li")
    list.each do |l|
      next if l.inner_text =~ /^\s+$/
      if !l.css("a").empty?
        url = "http://www.scaruffi.com/jazz/#{l.css('a').attr('href').to_s}"
        output = deep_merge(output, parse_specific_page(url))
        next
      end
      line = l.inner_text.gsub(/\(\d{4}\)/, '')
      year = l.inner_text.match(/\(.*(\d{4})\)/)[1]
      artist, album = line.split(":").map(&:strip)
      
      if output.has_key?(year)
        output[year] << {:artist => artist, :album => album}
      else
        output[year] = [{:artist => artist, :album => album}]
      end
    end
  end
  output
end

def deep_merge(hash1, hash2)
  new_hash = {}
  (hash1.keys | hash2.keys).each do |k|
    new_hash[k] = Array(hash1[k]) | Array(hash2[k])
  end
  new_hash
end

def parse_specific_page(url)
  puts "Parsing #{url}"
  doc = Nokogiri::HTML.parse(open(url))
  index = nil
  table_xpath = ''
  (1..10).each do |i|
    table_xpath = "//table[#{i}]/tr/td[3]/"
    heading = doc.xpath("#{table_xpath}b")
    if heading.inner_text !~ /Jazz/
      next
    else
      index = i
      break
    end
  end
  
  year = url.match(/(\d{4})\.html/)[1]
  output = {year => []}
  doc.xpath("#{table_xpath}font[1]/ol/li").each do |li|
    artist, album = li.inner_text.split(":").map(&:strip)
    output[year] << {:artist => artist, :album => album}
  end
  output
rescue Exception => e
  puts "Couldn't parse #{url} correctly :("
  puts e.message
end

def save_csv(output)
  CSV.open("jazz_albums.csv", 'wb') do |csv|
    csv << %w[Artist Album Year]
    output.each do |year, albums|
      albums.each do |album|
        csv << [album[:artist], album[:album], year]
      end
    end
  end
end

output = {}
1940.step(2000, 10).each do |yr|
  url = "http://www.scaruffi.com/jazz/#{yr.to_s[2..-1]}.html"
  output = deep_merge(output, parse_page(url))
end