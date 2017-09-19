require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'hashie'

require 'aws-sdk'
require 'faraday_middleware'
require 'faraday_middleware/aws_signers_v4'
require 'elasticsearch'

configure do
  ES_HOST = 'https://search-ivcf-search-test-x2j6naonm7izxd7ta7eeq6vw4e.us-east-1.es.amazonaws.com'
  creds = Aws::SharedCredentials.new # Assumes ~/.aws/credentials exists and has permissions
  @@es = Elasticsearch::Client.new url: ES_HOST do |f|
    f.request :aws_signers_v4,
      credentials: creds,
      service_name: 'es',
      region: 'us-east-1'
  end
end

# GET / is a summary view
get "/" do
  response = @@es.search(
    index: 'blog',
    body: {
      query: {},
      size: 5,
      sort: :created
    }
  )
  response = Hashie::Mash.new response

  slim :index, locals:{ posts: response.hits.hits }
end

# GET /blog/:post shows detail view for a specific post
get "/blog/:post" do
  response = @@es.get(index: :blog, type: :post, id: params[:post])
  post = Hashie::Mash.new response
  slim :post, locals: { post: post._source }
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

