require 'typhoeus'
require 'active_support'
require 'active_support/core_ext'

module Zm
  module Client
    class RestAccountConnector

      attr_reader :account, :files_error, :count_file

      def initialize(scheme, host, port, account)
        @scheme = scheme
        @host = host
        @port = port
        @account = account

        @count_file = 0
        @files_error = []
      end

      def post(file_path, destination_folder_path, fmt, resolve)
        @count_file += 1

        uri = make_url(destination_folder_path, fmt, resolve)

        request = Typhoeus::Request.new(
          uri.to_s,
          method: :post,
          body: { file: File.open(file_path,"r") },
          # headers: HTTP_HEADERS,
          # ssl_verifypeer: false,
          # verbose: true
        )

        request.on_complete do |response|
          if !response.success?
            @files_error << file_path
          end
        end

        request.run
        
      end

      def reset_log
        @count_file = 0
        @files_error.clear
      end
      
      private

      def make_params(fmt, resolve, token)
          {fmt: fmt, resolve: resolve, auth: :qp, zauthtoken: token}.to_query
      end

      def make_folder_path(destination_folder_path)
        URI.encode(File.join("","home", @account.name, destination_folder_path))
      end

      def make_url(destination_folder_path, fmt, resolve)
        URI::HTTP.new( @scheme, nil, @host, @port, nil, make_folder_path(destination_folder_path), nil, make_params(fmt, resolve, @account.token), nil )
      end

      # def curl_request(method, body, error_handler = SoapError)

      #   request = Typhoeus::Request.new(
      #     @uri.to_s,
      #     method: :post,
      #     body: body.to_json,
      #     headers: HTTP_HEADERS,
      #     ssl_verifypeer: false,
      #     # verbose: true
      #   )

      #   request.run
      # end

    end

  end
end
