# frozen_string_literal: true

require 'aws-sdk-s3'

# Adapt OTel
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
  def initialize
    super
    @file_name = 'dice-roll.txt'
    @s3 = Aws::S3::Client.new(
      region: 'eu-west-1',
      endpoint: 'http://localhost:4566',
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'test'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'test'),
      force_path_style: true
    )
  end

  def index
    @dice_roll = rand(1..6).to_s
    File.write("storage/#{@file_name}", "roll: #{@dice_roll}")

    OpenTelemetryAdapter.in_span(
      tracer_name: 'ruby_dice_app_tracer',
      span_name: 'writing to s3',
      kind: :producer
    ) { upload_to_s3 }
  end

  def upload_to_s3
    # empty hash that will hold the context
    metadata = {}
    # inject the context in the hash
    OpenTelemetryAdapter.inject_trace_context(target: metadata)
    File.open("storage/#{@file_name}", 'rb') do |file|
      @s3.put_object(bucket: ENV.fetch('BUCKET_NAME'), key: @file_name, body: file, metadata: metadata)
    end
  end

  def fake_worker
    @s3_file_object = @s3.get_object(bucket: ENV.fetch('BUCKET_NAME'), key: @file_name)
    # metadata = @s3.head_object(bucket: ENV['BUCKET_NAME'], key: @file_name).metadata
    context = OpenTelemetry.propagation.extract(@s3_file_object.metadata)
    tracer = ::OpenTelemetry.tracer_provider.tracer('fake_worker_tracer')
    # After extracting the context information from the metadata,
    # force the parent of the next span to be the uploading span:
    span = tracer.start_span('consuming from s3 and performing hard calculations', with_parent: context)
    @hard_calculations = 2 + 2
    span.finish # this is necessary as we dont use in_span.
    # We don't use in_span because with_parent is not available on it.
  end
end
