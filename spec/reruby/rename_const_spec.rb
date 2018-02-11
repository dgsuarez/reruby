require 'spec_helper'

describe Reruby::RenameConst do

  it "reports the files that changed in the refactoring" do
    finder_double = instance_double(
      Reruby::FileFinder,
      paths_containing_word: ["lib/a.rb", "lib/using_a.rb"]
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

    refactoring = Reruby::RenameConst.new(
      from: "A",
      to: "B",
      config: config_with_json_report
    )

    expect(refactoring).to receive(:print).with(%r{changed.*lib/using_a.rb.*renamed.*lib/a.rb.*lib/b.rb}m)

    refactoring.perform
  end

end
