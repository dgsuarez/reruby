module Reruby
  module Actions
    class BulkFileOperations

      def initialize(renames: [], creates: [], deletes: [])
        @renames = renames
        @creates = creates
        @deletes = deletes
      end

      def perform
        apply_renames
        apply_creates
      end

      private

      attr_reader :renames, :creates, :deletes

      def apply_renames
        renames.each do |original, destination|
          Reruby.logger.info "Renaming #{original} -> #{destination}"
          File.rename(original, destination)
        end
      end

      def apply_creates
        creates.each do |path, code|
          Reruby.logger.info "Writing #{path}"
          write_code_to_path(path, code)
        end
      end

      # :reek:UtilityFunction
      def write_code_to_path(path, code)
        folder = File.dirname(path)
        FileUtils.mkdir_p(folder)
        File.open(path, 'w') do |file|
          file << code
        end
      end

    end

  end
end
