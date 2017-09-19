require 'aws-sdk'
require 'faraday_middleware'
require 'faraday_middleware/aws_signers_v4'
require 'elasticsearch'

require 'cicero'
require 'image_suckr'

class Resource
  ES_HOST = 'https://search-ivcf-search-test-x2j6naonm7izxd7ta7eeq6vw4e.us-east-1.es.amazonaws.com'
  attr_accessor :es

  def initialize *args
    creds = Aws::SharedCredentials.new # Assumes ~/.aws/credentials exists and has permissions
    @es = Elasticsearch::Client.new url: ES_HOST do |f|
      f.request :aws_signers_v4,
            credentials: creds,
            service_name: 'es',
            region: 'us-east-1'
    end
  end

  def build_schema
    @es.indices.create(index: 'blog',
      body: {
        mappings: {
          post: {
            properties: {
              created: { type: 'date' },
              published: { type: 'date' },
              title: { type: 'text' },
              image: { type: 'text' },
              body: { type: 'text' }
            }
          }
        }
      }
    )

    @es.indices.create(index: 'resources',
      body: {
        mappings: {
          article: {
            properties: {
              created: { type: 'date' },
              published: { type: 'date' },
              title: { type: 'text' },
              image: { type: 'text' },
              body: { type: 'text' },
              files: { type: 'text' }
            }
          }
        }
      }
    )
  end

  def add_dummy_data
    suckr = ImageSuckr::GoogleSuckr.new

    10.times do |i|
      @es.create(
        index: 'blog',
        type: 'post',
        id: i,
        body: {
          title: Cicero.sentence,
          body: Cicero.paragraphs(3 + rand(5)),
          image: suckr.get_image_url,
          published: Time.now.utc.iso8601,
          created: Time.now.utc.iso8601
        }
      )
    end
  end
end
