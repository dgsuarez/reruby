module Reruby
  class BulkFileRenamer

    def self.bulk_rename(renames)
      renames.each do |original, destination|
        File.rename(original, destination)
      end
    end

  end
end
