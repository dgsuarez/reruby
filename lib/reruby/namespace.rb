module Reruby
  class Namespace

    def self.from_source(source)
      new(source.split("::"))
    end

    def initialize(const_groups)
      @const_groups = const_groups.map { |cg| cg.split("::") }
    end

    def can_resolve_to?(other_namespace)
      conditions = [
        has_all_consts_from_other?(other_namespace),
        last_const_group_resolves?(other_namespace)
      ]
      conditions.all?
    end

    def flat_namespace
      const_groups.flatten
    end

    def as_source
      flat_namespace.join("::")
    end

    def relative_path
      as_source.gsub("::", "/").underscore + ".rb"

    end

    def nesting_level_in(other_namespace)
      other_namespace.flat_namespace.zip(flat_namespace).each do |mine, other|
        return nil if mine != other
      end
      length - other_namespace.length
    end

    def ==(other)
      flat_namespace == other.flat_namespace
    end

    def eql?(other)
      flat_namespace.eql?(other.flat_namespace)
    end

    def hash
      flat_namespace.hash
    end

    def length
      flat_namespace.length
    end

    private

    attr_reader :const_groups

    def last_const_group_resolves?(other_namespace)
      my_last_const_group = const_groups.last.reverse
      his_namespace = other_namespace.flat_namespace.reverse

      his_last_consts = his_namespace.first(my_last_const_group.length)

      his_last_consts == my_last_const_group
    end

    def has_all_consts_from_other?(other)
      mine_until_his = flat_namespace
      other.flat_namespace.each do |his_const|
        mine_until_his = mine_until_his.drop_while do |my_const|
          my_const != his_const
        end

        return false if mine_until_his.empty?
        mine_until_his.slice(1)
      end

      true
    end
  end
end
