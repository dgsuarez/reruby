module Reruby
  module Actions
    class BulkFileRename

      def initialize(renames)
        @renames = renames
      end

      def perform
        renames.each do |original, destination|
          Reruby.logger.info "Renaming #{original} -> #{destination}"
          File.rename(original, destination)
        end
      end
    end

  end
end
