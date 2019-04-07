require 'spec_helper'

describe Reruby::ExtractMethod do

  it 'reports the files that changed in the refactoring' do
    action_double = instance_double(
      Reruby::Actions::FileRewrite,
      perform: nil,
      changed?: true
    )

    allow(Reruby::Actions::FileRewrite).to receive(:new) { action_double }

    allow(File).to receive(:read).with('lib/a.rb') { 'class A; class B; end; end' }

    refactoring = Reruby::ExtractMethod.new(
      location: 'lib/a.rb:0:0:10:10',
      name: 'new_method',
      config: config_with_json_report
    )

    expect(refactoring).to receive(:print).with(%r{changed.*lib/a.rb}m)

    refactoring.perform
  end

end
