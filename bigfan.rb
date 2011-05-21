require 'net/http'
require 'json'

#TODO: only show one tweet at a time
#TODO: add keyboard shortcuts for navigating between tweets
#TODO: style the single-tweet view a bunch
#TODO: add userpic
#TODO: add profile background image?
#TODO: add a way to get a link to the tweet/open in browser
 
Shoes.app :title => "Big Fan" do
  uri = URI.parse("http://www.twitter.com/favorites/ckolderup.json")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  @tweets = JSON.parse response.body

  stack do
    @tweets.each do |tweet|
      flow do
        para "@#{tweet["user"]["screen_name"]}"
        para tweet["text"]
      end
    end
  end
end
