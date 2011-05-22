require 'net/http'
require 'json'

module Bigfan
  def draw
    tweet = @tweets[@cur]
    username = tweet["user"]["screen_name"]
    profile_link = "http://www.twitter.com/#{username}"
    name = tweet["user"]["name"]
    text = tweet["text"]
    ts = tweet["created_at"]
    userpic = tweet["user"]["profile_image_url"]
    permalink = "http://www.twitter.com/#{username}/status/#{tweet["id"]}"

    @display.clear do

      flow :left => 15 do
        stack :width => 50, :left => 10, :top => 10 do
          image userpic
        end
        stack :width => 300, :top => 10 do
          caption link("@#{username}", 
                       :click => profile_link),
                       :margin_bottom => 2
          para name
        end
      end
      flow :left => 10 do
        tagline text
      end
    end

    @timestamp.clear do
      inscription link(ts, :click => permalink)
    end

    @progress.clear do
      inscription "#{@cur+1}/#{@tweets.size}"
    end
  end

  def fetch(page=1)

    uri = URI.parse("http://www.twitter.com/favorites/ckolderup.json?page=#{page}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if (response.code != "200") then
      return nil
    else
      return JSON.parse(response.body)
    end
  end
end

Shoes.app :height => 300, :width => 750, :title => "Big Fan", do
  extend Bigfan

  background cornflowerblue
  @cur = 0
  @timestamp = nil
  @progress = nil
  
  stack :height => 250, :top => 25, :width => 700, :left => 25 do
    background white
    @display = stack :height => 225 do
      para "Loading..."
    end
    flow do
      @timestamp = stack :width => 600 do
        inscription " "
      end
      @progress = stack :width => 50, :right => 5 do
        inscription " "
      end
    end
  end

  #parse tweets
  @tweets = fetch(1)
  @tweets += fetch(2)
  @tweets += fetch(3)
  @tweets = @tweets.take(50)
  
  #preload images
  stack :height => 20 do
    hide
    @tweets.each do |x|
      image x["user"]["profile_image_url"]
    end
  end
  
  #draw 
  draw

  keypress do |k|
    #changes
    @cur = @cur + 1 if (k == :down || k == :page_down || k == :space)
    @cur = @cur - 1 if (k == :up || k == :page_up || k == :shift_space)
    @cur = 0 if (k == :home)
    @cur = @tweets.size - 1 if (k == :end)

    #boundary checking
    @cur = 0 if @cur < 0
    @cur = @tweets.size - 1 if @cur >= @tweets.size

    #repaint
    draw
  end
end

