# frozen_string_literal: true

module DocumentFolder
  UUID_REGEX = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/.freeze

  def upload(file_path)
    uploader = Zm::Client::Upload.new(@parent, Zm::Client::RestAccountConnector.new)
    str = uploader.upload_attachment(file_path)

    uuid = str.scan(UUID_REGEX).first

    raise Zm::Client::RestError, 'failed to extract uuid' if uuid.nil?

    jsns = { doc: { l: @id, upload: { id: uuid } } }

    soap_request = Zm::Client::SoapElement.mail(Zm::Client::SoapMailConstants::SAVE_DOCUMENT_REQUEST).add_attributes(jsns)
    rep = @parent.sacc.invoke(soap_request)

    Zm::Client::DocumentJsnsInitializer.create(@parent, rep[:SaveDocumentResponse][:doc].first)
  end
end
