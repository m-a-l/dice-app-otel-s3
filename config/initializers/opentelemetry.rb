require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry-exporter-otlp'

# Export traces to console if variable is nil
# ENV['OTEL_TRACES_EXPORTER'] ||= 'console'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'dice-ruby'
  # prints stack error to stdout
  c.error_handler = ->(exception:, message:) { raise(exception || message) }
  c.logger = Logger.new($stderr, level: ENV.fetch('OTEL_LOG_LEVEL', 'fatal').to_sym)
  # config = { 'OpenTelemetry::Instrumentation::AwsSdk' => { enabled: false } }
  # c.use_all(config)
  c.use_all() # enables all instrumentation!
end
