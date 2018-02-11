module Reruby
  class ChangedFiles

    def initialize(**args)
      @changed = []
      @renamed = []
      @created = []
      @removed = []
      add(**args)
    end

    def to_h
      {
        changed: changed,
        renamed: renamed,
        created: created,
        removed: removed
      }
    end

    # :reek:LongParameterList
    def add(changed: [], renamed: [], created: [], removed: [])
      @renamed.concat(renamed)
      @changed.concat(changed)
      @created.concat(created)
      @removed.concat(removed)
      consolidate
      self
    end

    def merge(other)
      self.class.new
          .add(**to_h)
          .add(**other.to_h)
    end

    def merge!(other)
      add(**other.to_h)
    end

    # :reek:ControlParameter
    def report(format:)
      return unless format == 'json'

      JSON.pretty_generate(to_h) + "\n"
    end

    private

    attr_reader :changed, :renamed, :created, :removed

    def consolidate
      changed.delete_if do |path|
        renamed.map(&:first).include?(path) ||
          removed.include?(path)
      end

      [changed, renamed, created, removed].each(&:uniq!)
    end

  end
end
