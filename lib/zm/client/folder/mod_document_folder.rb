# frozen_string_literal: true

module DocumentFolder
  UUID_REGEX = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/.freeze

  def upload(file_path)
    uploader = Zm::Client::Upload.new(@parent, Zm::Client::RestAccountConnector.new)
    str = uploader.upload_attachment(file_path)

    uuid = str.scan(UUID_REGEX).first

    raise Zm::Client::RestError, 'failed to extract uuid' if uuid.nil?

    # upload_options = { upload: { id: uuid } }
    # rep = @parent.sacc.save_document(@parent.token, id, upload_options)
    jsns = { doc: { l: l, pload: { id: uuid } } }
    rep = @parent.sacc.jsns_request(:SaveDocumentRequest, @parent.token, jsns)

    # Zm::Client::Document.new(@parent, rep[:Body][:SaveDocumentResponse][:doc].first)
    DocumentJsnsInitializer.create(@parent, rep[:Body][:SaveDocumentResponse][:doc].first)
  end
end
