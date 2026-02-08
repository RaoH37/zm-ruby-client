# frozen_string_literal: true

module Zm
  module Error
    autoload :ZmError, 'zm/error/zm_error'
    autoload :SoapError, 'zm/error/soap_error'
    autoload :AuthError, 'zm/error/auth_error'
    autoload :RestError, 'zm/error/rest_error'
  end
end
