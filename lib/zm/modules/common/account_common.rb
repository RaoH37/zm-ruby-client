# module AccountCommon
#   ALL_ATTRS = JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '/zimbra-attrs.json')))
#   ATTRS_READ = ALL_ATTRS.select{|a|a['immutable']=='1'}.map{|a|a['name']}
#   ATTRS_WRITE = ALL_ATTRS.reject{|a|a['immutable']=='1'}.map{|a|a['name']}
#
#   ZM_ACCOUNT_ATTRS = %w[
#     sn
#     company
#     cn
#     co
#     street
#     l
#     givenName
#     postalAddress
#     postalCode
#     displayName
#     gidNumber
#     telephoneNumber
#     description
#     zimbraPrefGroupMailBy
#     zimbraPrefFromDisplay
#     zimbraPrefFromDisplay
#     zimbraPrefMailSignature
#     zimbraPrefMailSignatureHTML
#     zimbraPrefMailSignatureStyle
#     zimbraPrefDefaultSignatureId
#     zimbraPrefForwardReplySignatureId
#     zimbraPrefReplyToEnabled
#     zimbraPrefIdentityName
#     zimbraPrefFromAddress
#     zimbraPrefWhenInFoldersEnabled
#     zimbraPrefWhenSentToEnabled
#     zimbraPrefSortOrder
#     zimbraSignatureName
#     userPassword
#     zimbraPasswordMustChange
#     zimbraPrefOutOfOfficeFromDate
#     zimbraPrefOutOfOfficeReplyEnabled
#     zimbraPrefOutOfOfficeUntilDate
#     zimbraPrefOutOfOfficeReply
#     zimbraAccountStatus
#     zimbraMailStatus
#     zimbraPasswordMustChange
#     zimbraPrefSortOrder
#     zimbraMailSieveScript
#     zimbraPrefTasksReadingPaneLocation
#     zimbraPrefShowCalendarWeek
#     zimbraPrefForwardIncludeOriginalText
#     zimbraPrefReplyIncludeOriginalText
#     zimbraPrefHtmlEditorDefaultFontFamily
#     zimbraPrefZimletTreeOpen
#     zimbraPrefComposeFormat
#     zimbraPrefFolderTreeOpen
#     zimbraPrefCalendarFirstDayOfWeek
#     zimbraPrefCalendarForwardInvitesTo
#     zimbraPrefMailForwardingAddress
#     zimbraMailDeliveryAddress
#     zimbraCOSId
#   ].freeze
#
#   ATTRS_READ.each { |attr| attr_reader attr }
#   ATTRS_WRITE.each { |attr| attr_accessor attr }
#
#   def attrs_read
#     ATTRS_READ
#   end
#
#   def attrs_write
#     ATTRS_WRITE
#   end
# end
