# frozen_string_literal: true

module Zm
  module Client
    # mountpoints returned by MountPointsCollection#all
    class MountPointsResponse < Array
      include FolderViewFilters
    end
  end
end
