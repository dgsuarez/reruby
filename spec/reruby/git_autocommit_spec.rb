# frozen_string_literal: true

require 'spec_helper'

describe Reruby::GitAutocommit do

  it 'calls to add and commit when autocommit' do
    expect_any_instance_of(Git::Base).to receive(:add).with(all: true).once
    expect_any_instance_of(Git::Base).to receive(:commit).with('test autocommit message').once
    subject.autocommit('test autocommit message')
  end

  it 'raises AutocommitError if there is an error in the autocommit' do
    expect_any_instance_of(Git::Base).to receive(:add).with(all: true).and_raise('fake error')
    expect { subject.autocommit('test autocommit message') }.to raise_error(Reruby::AutocommitError)
  end

end
