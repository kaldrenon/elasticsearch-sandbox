Elastichsearch test
===================

A simple test with [Elasticsearch](http://www.elasticsearch.org/)

# Get it up and running

    To access the server I'm using, you'll need [AWS Shared Credentials](https://aws.amazon.com/blogs/security/a-new-and-standardized-way-to-manage-credentials-in-the-aws-sdks/) set up on your local machine, and you'll also need to be on my employer's VPN.
    To try this with your own ES instance, change the `ES_HOST` value in [server.rb](https://github.com/kaldrenon/elasticsearch-sandbox/blob/master/server.rb#L12)

    brew install elasticsearch
    elasticsearch -f
    bundle install
    bundle exec ruby server.rb
    open http://localhost:4567

