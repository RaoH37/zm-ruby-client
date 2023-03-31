module SignatureCommon
  ALL_ATTRS = %w[zimbraSignatureId zimbraSignatureName zimbraPrefMailSignatureHTML zimbraPrefMailSignature].freeze
  ATTRS_READ = []
  ATTRS_WRITE = ALL_ATTRS

  ATTRS_READ.each { |attr| attr_reader attr }
  ATTRS_WRITE.each { |attr| attr_accessor attr }

  def attrs_read
    ATTRS_READ
  end

  def attrs_write
    ATTRS_WRITE
  end
end
