require './app'
require './crawl_exercise'

Dir[File.dirname(__FILE__) + '/workers/*.rb'].each {|file| require file }

map('/') { run App }
map('/crawl') { run CrawlExercise }
