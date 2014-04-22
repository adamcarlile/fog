module Fog
  module AWS
    class SQS
      class Real

        require 'fog/aws/parsers/sqs/basic'

        # Get attributes of a queue
        #
        # ==== Parameters
        # * queue_url<~String> - Url of queue to get attributes for
        # * attribute_name<~String> - Name of attribute to set, keys in ['MaximumMessageSize', 'MessageRetentionPeriod', 'Policy', 'VisibilityTimeout']
        # * attribute_value<~String> - Value to set for attribute
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AWSSimpleQueueService/latest/APIReference/Query_QuerySetQueueAttributes.html
        #

        def set_queue_attributes(queue_url, attribute_name, attribute_value)
          hash = {
            'Action'        => 'SetQueueAttributes',
            :path           => path_from_queue_url(queue_url),
            :parser         => Fog::Parsers::AWS::SQS::Basic.new
          }
          [attribute_name].flatten.each_with_index do |attribute, index|
            hash["Attribute.entry.#{index + 1}"] = attribute
          end
          request(hash)
        end

      end

      class Mock
        def set_queue_attributes(queue_url, attribute_name, attribute_value)
          Excon::Response.new.tap do |response|
            if (queue = data[:queues][queue_url])
              response.status = 200
              queue['Attributes'][attribute_name] = attribute_value
              response.body = {
                'ResponseMetadata' => {
                  'RequestId' => Fog::AWS::Mock.request_id
                }
              }
            else
              response.status = 404
              raise(Excon::Errors.status_error({:expects => 200}, response))
            end
          end
        end
      end
    end
  end
end
