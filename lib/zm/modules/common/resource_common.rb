module ResourceCommon
  ALL_ATTRS = %w[zimbraAccountCalendarUserType displayName zimbraCalResAutoDeclineIfBusy zimbraCalResType zimbraMailStatus zimbraMailDeliveryAddress zimbraAccountStatus cn sn zimbraCalResAutoAcceptDecline zimbraCalResContactEmail
                 zimbraCalResContactName zimbraCalResContactPhone zimbraCalResSite zimbraCalResRoom zimbraNotes zimbraCalResLocationDisplayName description userPassword].freeze
  ATTRS_READ = []
  ATTRS_WRITE = %w[zimbraAccountCalendarUserType displayName zimbraCalResAutoDeclineIfBusy zimbraCalResType zimbraMailStatus zimbraAccountStatus cn sn zimbraCalResAutoAcceptDecline zimbraCalResContactEmail
  zimbraCalResContactName zimbraCalResContactPhone zimbraCalResSite zimbraCalResRoom zimbraNotes zimbraCalResLocationDisplayName description userPassword].freeze

  ATTRS_READ.each { |attr| attr_reader attr }
  ATTRS_WRITE.each { |attr| attr_accessor attr }

  def attrs_read
    ATTRS_READ
  end

  def attrs_write
    ATTRS_WRITE
  end
end
