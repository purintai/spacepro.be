class CrawlExercise < App
  get '/' do
    slim :'crawl/index'
  end

  # http://www.town.higashikagura.lg.jp/live/live.php
  get '/stream' do
    content_type :txt

    poem = %w(クソッタレの世界のため 全てのクズ共のために 僕や君や彼等のため 明日には笑えるように)
    stream do |out|
      0.upto(Float::INFINITY) do |i|
        out << "終わらない歌を歌おう\n"
        sleep 1
        out << "#{poem[i % 4]}\n"
        sleep 1
      end
    end
  end

  # https://github.com/hitode909/great-redirect-loop
  get '/redirect_loop' do
    redirect '/crawl/redirect_loop'
  end

  get '/redirect_loop/:number' do
    redirect "/crawl/redirect_loop/#{params[:number].to_i + 1}"
  end
end
