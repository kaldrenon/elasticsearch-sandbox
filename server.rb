require 'sinatra'
require 'stretcher'
require 'slim'

class Resources
  def self.match(text)
    ES.index(:resources).search size: 1000, query: {
      multi_match: { query: text, fields: [:title, :description] }
    }
  end
end

configure do
  ES = Stretcher::Server.new('http://localhost:9200')
end

get "/" do
  resources = ES.index(:resources).type(:resource).search(size: 5, query: {match_all: {}})
  slim :index, locals: { resources: resources }
end

get "/blog" do
  posts = ES.index(:blog).type(:post).search(size: 5, query: {match_all: {}})
  slim :blog, locals: { posts: posts }
end

get "/blog/:post" do
  post = ES.index(:blog).type(:post).get(params[:post])
  slim :post, locals: { post: post }
end

get "/s/:search" do
  erb :result, locals: { resources: Resources.match(params[:search]) }
end

post "/" do
  # insert data
  ES.index(:resources).type(:resource).post({
    title: params[:title],
    body:  params[:body],
    created: Time.now
  })

  "<a href='/'>go back</a>"
end

