# frozen_string_literal: true

module Reruby

  class TextRange

    attr_reader :start_line, :start_col, :end_line, :end_col

    def self.parse(range_expression)
      params = range_expression.split(':').map(&:to_i)

      if params.length == 1
        single_line_range_extras = [0, params.first, 100_000]
        params.concat(single_line_range_extras)
      end

      new(*params)
    end

    def self.from_node_range(node_range)
      new(node_range.line,
          node_range.column,
          node_range.last_line,
          node_range.last_column - 1)
    end

    def initialize(start_line, start_col, end_line, end_col)
      @start_line = start_line
      @start_col = start_col
      @end_line = end_line
      @end_col = end_col
    end

    def includes?(other_region)
      starts_before?(other_region) && ends_after?(other_region)
    end

    def includes_node?(node)
      return false unless node

      node_range = node.loc.expression
      return false unless node_range

      node_text_range = Reruby::TextRange.from_node_range(node_range)

      includes?(node_text_range)
    end

    protected

    def starts_before?(other_region)
      other_start_line = other_region.start_line

      if start_line == other_start_line
        start_col <= other_region.start_col
      else
        start_line < other_start_line
      end
    end

    def ends_after?(other_region)
      other_end_line = other_region.end_line

      if end_line == other_end_line
        end_col >= other_region.end_col
      else
        end_line > other_end_line
      end
    end
  end
end
