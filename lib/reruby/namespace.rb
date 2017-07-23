module Reruby
  class Namespace

    class Base
      def relative_path
        "#{as_require}.rb"
      end

      def as_require
        flat_namespace.join("/").underscore
      end

      def as_source
        flat_namespace.join("::")
      end

      def nesting_level_in(other_namespace)
        other_namespace.flat_namespace.zip(flat_namespace).each do |mine, other|
          return nil if mine != other
        end
        length - other_namespace.length
      end

      def relativize
        Namespace.from_list(flat_namespace)
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

      def empty?
        length == 0
      end

      def adding(new_part)
        if new_part.is_a?(Root)
          Relative.new([new_part])
        else
          Relative.new(@parts + [new_part])
        end
      end

      protected

      def subnamespaces_of_size(size)
        possibles = flat_namespace.each_with_index.map do |_, i|
          flat_namespace.slice(i, size)
        end

        possibles.reject {|w| w.length != size }
      end
    end

    class Absolute < Base

      def initialize(consts)
        @consts = consts
      end

      def can_resolve_to?(other_namespace)
        included?(other_namespace)
      end

      def flat_namespace
        consts
      end

      def to_s
        "#{self.class.name} #{as_source}"
      end

      def parts
        [self]
      end

      def index_in(other_namespace)
        reversed_sub_consts = other_namespace.subnamespaces_of_size(consts.length).reverse
        remaining_consts = reversed_sub_consts.drop_while do |other_consts|
          other_consts != consts
        end

        if remaining_consts.empty?
          nil
        else
          remaining_consts.flatten.count - 1
        end
      end

      def included?(other_namespace)
        index_in(other_namespace)
      end

      def take_n_consts(n)
        self.class.new(consts.take(n))
      end

      private

      attr_reader :consts
    end

    class Root < Absolute

      def as_source
        "::" + super
      end

      def index_in(other_namespace)
        beginning_of_other = other_namespace.subnamespaces_of_size(consts.length).first
        if beginning_of_other == consts
          0
        else
          nil
        end
      end

      def included?(other_namespace)
        index_in(other_namespace)
      end

    end

    class Relative < Base

      attr_reader :parts

      def initialize(parts)
        @parts = parts
      end

      def to_s
        "#{self.class.to_s} #{parts.map(&:to_s)}"
      end

      def flat_namespace
        parts.flat_map(&:flat_namespace)
      end

      def can_resolve_to?(other_namespace)
        has_all_consts_from?(other_namespace) && last_part_resolves?(other_namespace)
      end

      def has_all_consts_from?(other_namespace)
        ns_to_check = self

        other_namespace.parts.reverse.each do |part|
          part_idx = part.index_in(ns_to_check)
          return false unless part_idx
          ns_to_check = ns_to_check.take_n_consts(part_idx)
        end
      end


      def take_n_consts(n)
        ret = Relative.new([])
        parts.each do |part|
          max_consts_to_take = n - ret.length
          return ret if max_consts_to_take <= 0
          ret = ret.adding(part.take_n_consts(max_consts_to_take))
        end
        ret
      end

      def last_part_resolves?(other_namespace)
        parts.last.included?(other_namespace)
      end

    end

    class Tracker

      attr_reader :namespace

      def initialize
        @namespace = Relative.new([])
      end

      def open_namespace(ns_to_open, &b)
        old_namespace = namespace
        @namespace = namespace.adding(ns_to_open)

        yield

        @namespace = old_namespace
      end

    end

    def self.from_source(source)
      Absolute.new(source.split("::"))
    end

    def self.from_list(list)
      absolutes = list.map do |source|
        from_source(source)
      end

      Relative.new(absolutes)
    end

  end
end
