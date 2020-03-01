# frozen_string_literal: true

require 'spec_helper'

describe Reruby::TextRange do

  it 'parses full ranges' do
    parsed = Reruby::TextRange.parse('1:1:5:6')

    expect(parsed.start_line).to eq 1
    expect(parsed.end_col).to eq 6
  end

  it 'parses single line ranges, setting the columns to appropiate values' do
    parsed = Reruby::TextRange.parse('1')

    expect(parsed.start_line).to eq 1
    expect(parsed.end_line).to eq 1
    expect(parsed.start_col).to eq 0
    expect(parsed.end_col).to eq 100_000
  end

end
