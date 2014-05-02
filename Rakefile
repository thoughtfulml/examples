require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/lib/*_spec.rb']
  t.verbose = true
end

task :console do
  require 'irb'
  require 'irb/completion'
  require './lib/part_of_speech_tagger.rb'
  ARGV.clear
  IRB.start
end
