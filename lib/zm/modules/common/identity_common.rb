module IdentityCommon
  ALL_ATTRS = %w[zimbraPrefForwardIncludeOriginalText zimbraPrefUseDefaultIdentitySettings zimbraPrefMailSignatureStyle
  zimbraPrefMailSignatureEnabled zimbraPrefIdentityId zimbraPrefForwardReplyFormat zimbraPrefReplyIncludeOriginalText
  zimbraPrefForwardReplyPrefixChar zimbraPrefWhenSentToAddresses zimbraPrefFromDisplay zimbraPrefForwardReplySignatureId
  zimbraPrefReplyToEnabled zimbraPrefIdentityName zimbraPrefFromAddress zimbraPrefWhenInFoldersEnabled zimbraPrefWhenSentToEnabled].freeze
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
