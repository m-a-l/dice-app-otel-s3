# frozen_string_literal: true
require 'aws-sdk-s3'

class OpenTelemetryAdapter
  def self.inject_trace_context(target:)
    OpenTelemetry.propagation.inject(target)
  end

  def self.in_span(tracer_name:, span_name:, kind:, attributes: nil, links: [], &block)
    tracer = ::OpenTelemetry.tracer_provider.tracer(tracer_name)
    tracer.in_span(
      span_name,
      attributes: attributes,
      kind: kind,
      links: links,
      &block
    )
  end

  def self.add_attributes(attributes)
    OpenTelemetry::Trace.current_span.add_attributes(attributes)
  end
end

# Roll a dice !
class DiceController < ApplicationController
  def s3
    Aws::S3::Client.new(
      region: 'eu-west-1',
      endpoint: 'http://localhost:4566',
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'test'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'test'),
      force_path_style: true
    )
  end

  def index
    OpenTelemetryAdapter.in_span(
      tracer_name: 'ruby_dice_app',
      span_name: "writing to s3",
      kind: :producer
    ) { upload_to_s3 }
  end

  def upload_to_s3
    metadata = {}

    OpenTelemetryAdapter.inject_trace_context(target: metadata)
    s3.put_object(bucket: 'dice-app-bucket', key: 'file_name.txt', body: 'object content', metadata: metadata)
  end

  def retrieve
    metadata = s3.head_object(bucket: 'dice-app-bucket', key: 'file_name.txt').metadata
    context = OpenTelemetry.propagation.extract(metadata)
    tracer = ::OpenTelemetry.tracer_provider.tracer('second service')
    span = tracer.start_span('consuming from s3', with_parent: context)

    p "some hard calculations"
    2 + 2
    span.finish
  end
end
