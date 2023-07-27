# frozen_string_literal: true
require 'aws-sdk-s3'

# Roll a dice !
class DiceController < ApplicationController
  def index
    file_name = 'dice-roll.txt'
    @dice_roll = rand(1..6).to_s
    logger.info "roll: #{@dice_roll}"
    File.write("storage/#{file_name}", "roll: #{@dice_roll}")
    logger.info "written to file #{file_name}"
    upload_to_s3(file_name)
  end

  def upload_to_s3(file_name)
    # binding.pry
    target = {}
    OpenTelemetry.propagation.inject(target)
    s3 = Aws::S3::Client.new(
      region: 'eu-west-1',
      endpoint: 'http://localhost:4566',
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'test'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'test'),
      force_path_style: true
    )
    File.open("storage/#{file_name}", 'rb') do |file|
      s3.put_object(
        bucket: 'dice-app-bucket',
        key: 'dice-roll-s3.txt',
        body: file,
        metadata: {
          # traceid: OpenTelemetry::Trace.current_span.context.trace_id,
          traceparent: target['traceparent'],
          # baggage: target['baggage'],
          # tracestate: target['tracestate']
        }
      )
    end
  end

  def retrieve
    metadata = s3.head_object(bucket: 'dice-app-bucket', key: 'dice-roll-s3.txt').metadata
    context = OpenTelemetry.propagation.extract(metadata, OpenTelemetry::Context.empty)
  end
end
