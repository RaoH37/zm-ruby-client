module DocumentFolder
  UUID_REGEX = %r{[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}:[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}}

  def upload(file_path)
    puts "Document folder: #{file_path}"
    uploader = Zm::Client::Upload.new(@parent, Zm::Client::RestAccountConnector.new)
    str = uploader.upload_attachment(file_path)
    uuid = str.scan(UUID_REGEX).first
    upload_options = { upload: { id: uuid } }
    @parent.sacc.save_document(@parent.token, id, upload_options)
  end
end