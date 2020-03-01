# frozen_string_literal: true

require 'spec_helper'

describe Reruby::ChangedFiles do

  it 'records file operations' do
    files = Reruby::ChangedFiles.new
    files.add(created: %w[a b], renamed: [%w[c d]])

    expect(files.to_h[:created]).to eq %w[a b]
    expect(files.to_h[:renamed]).to eq([%w[c d]])
  end

  it 'merges with other changes in a new instance' do
    files = Reruby::ChangedFiles.new(created: %w[a b], renamed: [%w[c d]])
    other_files = Reruby::ChangedFiles.new(created: %w[j k])

    merged_files = files.merge(other_files)

    expect(merged_files.to_h[:created]).to eq %w[a b j k]
    expect(merged_files.to_h[:renamed]).to eq([%w[c d]])
  end

  it 'untracks a changed file when it has been renamed' do
    files = Reruby::ChangedFiles.new(changed: %w[a b])

    files.add(renamed: [%w[a c]])

    expect(files.to_h[:changed]).to eq ['b']
  end

  it 'untracks a changed file when int has been deleted' do
    files = Reruby::ChangedFiles.new(changed: %w[a b])

    files.add(removed: %w[a c])

    expect(files.to_h[:changed]).to eq ['b']
  end

  it "doesn't keep duplicates" do
    files = Reruby::ChangedFiles.new(created: %w[a a a])

    expect(files.to_h[:created]).to eq ['a']
  end

end
