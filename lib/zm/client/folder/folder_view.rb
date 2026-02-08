# frozen_string_literal: true

module Zm
  module Client
    module FolderView
      UNKNOWN = 'unknown'
      MESSAGE = 'message'
      APPOINTMENT = 'appointment'
      TASK = 'task'
      DOCUMENT = 'document'
      CONTACT = 'contact'
      ALL = [MESSAGE, APPOINTMENT, TASK, DOCUMENT, CONTACT].freeze
    end
  end
end
