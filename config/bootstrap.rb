require 'bundler'
Bundler.require

Dir['./lib/*.rb'].each do |_|
  require _
end