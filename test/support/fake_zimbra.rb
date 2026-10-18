# frozen_string_literal: true

require 'json'
require 'faraday'

module ZmTest
  class FakeZimbra
    class UnexpectedRequest < StandardError; end

    Request = Data.define(:name, :body, :header, :path)

    attr_reader :requests

    class << self
      attr_accessor :current
    end

    def initialize
      @handlers = {}
      @requests = []
    end

    def on(request_name, response = nil, &block)
      @handlers[request_name.to_s] = block || ->(_request) { response }
      self
    end

    def fault(request_name, code:, reason: code, status: 500)
      body = { Fault: { Code: { Value: 'soap:Sender' }, Reason: { Text: reason }, Detail: { Error: { Code: code } } } }
      on(request_name) { [status, body] }
    end

    def network_error(request_name, error = Faraday::ConnectionFailed.new('Connection refused'))
      on(request_name) { raise error }
    end

    def last_request(request_name = nil)
      return @requests.last if request_name.nil?

      @requests.reverse_each.find { |request| request.name == request_name.to_s }
    end

    def call(env)
      payload = JSON.parse(env.request_body, symbolize_names: true)
      name, body = payload[:Body].first
      request = Request.new(name: name.to_s, body:, header: payload[:Header], path: env.url.path)
      @requests << request

      handler = @handlers.fetch(request.name) do
        raise UnexpectedRequest, "no fake response registered for #{request.name}"
      end

      status, response_body = normalize(handler.call(request))
      return [status, { 'Content-Type' => 'text/html' }, response_body] if response_body.is_a?(String)

      [status, { 'Content-Type' => 'application/json' }, JSON.generate({ Header: {}, Body: response_body })]
    end

    private

    def normalize(result)
      result.is_a?(Array) ? result : [200, result]
    end

    # Faraday adapter forwarding every HTTP call to FakeZimbra.current.
    class Adapter < Faraday::Adapter
      def call(env)
        super
        fake = FakeZimbra.current or raise UnexpectedRequest, 'FakeZimbra.current is not set'
        status, headers, body = fake.call(env)
        save_response(env, status, body, headers)
        @app.call(env)
      end
    end
  end
end

Faraday::Adapter.register_middleware(fake_zimbra: ZmTest::FakeZimbra::Adapter)
