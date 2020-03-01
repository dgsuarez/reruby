# frozen_string_literal: true

require 'spec_helper'

describe Reruby::ExplodeNamespace do

  it 'reports the files that changed in the refactoring' do
    finder_double = instance_double(
      Reruby::FileFinder,
      paths_containing_word: ['lib/a.rb']
    )

    action_double = instance_double(
      Reruby::Actions::FileRewrite,
      perform: nil,
      changed?: true
    )

    allow(Reruby::FileFinder).to receive(:new) { finder_double }
    allow(Reruby::Actions::FileRewrite).to receive(:new) { action_double }

    allow(Reruby::Actions::BulkFileOperations).to receive(:new) do |**args|
      NoopBulkFileOperations.new(**args)
    end

    allow(File).to receive(:read).with('lib/a.rb') { 'class A; class B; end; end' }

    refactoring = Reruby::ExplodeNamespace.new(
      namespace_to_explode: 'A',
      config: config_with_json_report
    )

    expect(refactoring).to receive(:print).with(%r{changed.*lib/a.rb.*created.*lib/a/b.rb}m)

    refactoring.perform
  end

end
