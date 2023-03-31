module DistributionListCommon
  ALL_ATTRS = %w[
    mail
    zimbraMailStatus
    displayName
    zimbraMailAlias
    cn
    zimbraMailForwardingAddress
    description
    zimbraDistributionListSendShareMessageToNewMembers
    zimbraHideInGal
    zimbraNotes
  ].freeze

  ATTRS_READ = %w[zimbraMailAlias zimbraACE]

  ATTRS_WRITE = %w[
    zimbraMailStatus
    displayName
    cn
    zimbraMailTransport
    zimbraMailForwardingAddress
    description
    zimbraHideInGal
    zimbraDistributionListSendShareMessageToNewMembers
  ].freeze

  ATTRS_READ.each { |attr| attr_reader attr }
  ATTRS_WRITE.each { |attr| attr_accessor attr }

  def attrs_read
    ATTRS_READ
  end

  def attrs_write
    ATTRS_WRITE
  end
end
