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
      self
    end

    def merge(other)
      self.class.new
          .add(**to_h)
          .add(**other.to_h)
    end

    private

    attr_reader :changed, :renamed, :created, :removed

  end
end
