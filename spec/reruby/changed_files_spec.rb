require 'spec_helper'

describe Reruby::ChangedFiles do

  it "records file operations" do
    files = Reruby::ChangedFiles.new
    files.add(created: %w[a b], renamed: [%w[c d]])

    expect(files.to_h[:created]).to eq %w[a b]
    expect(files.to_h[:renamed]).to eq([%w[c d]])
  end

  it "merges with other changes in a new instance" do
    files = Reruby::ChangedFiles.new(created: %w[a b], renamed: [%w[c d]])
    other_files = Reruby::ChangedFiles.new(created: %w[j k])

    merged_files = files.merge(other_files)

    expect(merged_files.to_h[:created]).to eq %w[a b j k]
    expect(merged_files.to_h[:renamed]).to eq([%w[c d]])
  end

end
