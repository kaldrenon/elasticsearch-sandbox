require 'aws-sdk'
require 'faraday_middleware'
require 'faraday_middleware/aws_signers_v4'
require 'elasticsearch'

class Resource
  ES_HOST = 'https://search-ivcf-search-test-x2j6naonm7izxd7ta7eeq6vw4e.us-east-1.es.amazonaws.com'
  attr_accessor :es

  def initialize *args
    creds = Aws::SharedCredentials.new
    @es = Elasticsearch::Client.new url: ES_HOST do |f|
      f.request :aws_signers_v4,
            credentials: creds,
            service_name: 'es',
            region: 'us-east-1'
    end
  end

  def build_schema
    @es.index(:blog).create(mappings: {
      post: {
        properties: {
          created: { type: 'date' },
          published: { type: 'date' },
          title: { type: 'text' },
          image: { type: 'text' },
          body: { type: 'text' }
        }
      }
    })

    @es.index(:resources).create(mappings: {
      article: {
        properties: {
          created: { type: 'date' },
          published: { type: 'date' },
          title: { type: 'text' },
          image: { type: 'text' },
          body: { type: 'text' },
          files: { type: 'array' }
        }
      }
    })
  end
end
