require './app'
require './crawl_exercise'

map('/') { run App }
map('/crawl') { run CrawlExercise }
