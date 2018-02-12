module Reruby

  class TextRange

    attr_reader :start_line, :start_col, :end_line, :end_col

    def self.parse(range_expression)
      params = range_expression.split(":").map(&:to_i)
      new(*params)
    end

    def self.from_node_range(node_range)
      new(node_range.line,
          node_range.column,
          node_range.last_line,
          node_range.last_column)
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
        end_col >= other_end_line
      else
        end_line > other_end_line
      end
    end
  end
end
