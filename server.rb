require 'sinatra'
require 'sinatra/reloader'
require 'stretcher'
require 'slim'

class Posts
  def self.match(text)
    ES.index(:blog).type(:post).search(
      size: 1000,
      query: {
        multi_match: {
          query: text,
          fields: [:title, :teaser]
        }
      }
    )
  end
end

configure do
  ES = Stretcher::Server.new('http://localhost:9200')
end

# GET / is a summary view
get "/" do
  resources = ES.index(:resources).type(:resource).search(size: 5, query: {match_all: {}})
  slim :index, locals: { resources: resources }
end

# POST / adds a blog post
post "/" do
  # insert data
  ES.index(:resources).type(:resource).post({
    title: params[:title],
    body:  params[:body],
    created: Time.now
  })

  "<a href='/'>go back</a>"
end

# GET /blog lists 5 blog posts
get "/blog" do
  posts = ES.index(:blog).type(:post).search(size: 5, query: {match_all: {}})
  slim :blog, locals: { posts: posts }
end


# GET /blog/:post shows detail view for a specific post
get "/blog/:post" do
  post = ES.index(:blog).type(:post).get(params[:post])
  slim :post, locals: { post: post }
end

# GET /search shows the search form
get "/search" do
  slim :search, locals: { search: '', results: nil }
end

# POST /search shows search results
post "/search" do
  puts params
  slim :search, locals: { search: params[:search], results: Posts.match(params[:search]) }
end

