module DistributionListCommon
  ALL_ATTRS = %w[zimbraMailStatus displayName zimbraMailAlias cn zimbraMailForwardingAddress].freeze
  ATTRS_READ = []
  ATTRS_WRITE = %w[zimbraMailStatus displayName cn].freeze

  ATTRS_READ.each { |attr| attr_reader attr }
  ATTRS_WRITE.each { |attr| attr_accessor attr }

  def attrs_read
    ATTRS_READ
  end

  def attrs_write
    ATTRS_WRITE
  end
end
