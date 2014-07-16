require 'rest-client'
require 'json'
require 'csv'

def more_info(artist, album)
  discogs = "http://api.discogs.com/database/search?q=#{artist} #{album}&type=master&per_page=1"
  JSON.parse(RestClient.get(URI.escape(discogs)))
rescue => ex
  puts ex.message
  {}
end


relevant_info = {}


CSV.foreach('./jazz_albums.csv', :headers => true) do |row|
  key = [row['Artist'], row['Album']].join(' ')
  if relevant_info.has_key?(key)
    
  else
    puts "Getting data for #{row}"
    data = more_info(row['Artist'], row['Album'])
    master_info = data.fetch('results', []).first || {}
    relevant_info[key] = {
      :year => row['Year'], 
      :styles => master_info.fetch('style', []),
    }
    sleep 1
  end
end

uniq_styles = relevant_info.map {|k,v| v[:styles] }.flatten.uniq.sort

artists = {}

CSV.foreach('./jazz_albums.csv', :headers => true) do |row|
  key = [row['Artist'], row['Album']].join(' ')
  artists[key] = row['Artist']
end

CSV.open('./annotated_jazz_albums.csv', 'wb') do |csv|
  csv << %w[artist_album key_index year].concat(uniq_styles)

  relevant_info.each do |k,v|
    styles = uniq_styles.map {|uu| v[:styles].include?(uu) ? 1 : 0 }
    csv << [k, artists.keys.index(k), v[:year]].concat(styles)
  end
end
