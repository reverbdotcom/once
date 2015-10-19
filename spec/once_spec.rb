require 'spec_helper'
require 'once'
require 'fakeredis/rspec'
require 'timecop'

describe Once do
  before do
    Once.redis = Redis.new
  end

  let(:thing_to_execute)  { double(execute: "foo") }
  let(:params) {{foo: "bar"}}

  it "executes the given command" do
    described_class.do(name: "mycheck", params: params) do
      thing_to_execute.execute
    end

    thing_to_execute.should have_received(:execute).once
  end

  it "returns the result of the command" do
    described_class.do(name: "mycheck", params: params) do
      thing_to_execute.execute
    end.should == "foo"
  end

  it "executes when called from within different namespaces" do
    described_class.do(name: "mycheck1", params: params) do
      thing_to_execute.execute
    end
    described_class.do(name: "mycheck2", params: params) do
      thing_to_execute.execute
    end

    thing_to_execute.should have_received(:execute).twice
  end

  it "executes when given different params" do
    described_class.do(name: "mycheck", params: {foo: "bar"}) do
      thing_to_execute.execute
    end
    described_class.do(name: "mycheck", params: {baz: "quux"}) do
      thing_to_execute.execute
    end

    thing_to_execute.should have_received(:execute).twice
  end

  it "does not execute twice within a period of time" do
    2.times do
      described_class.do(name: "mycheck", params: params) do
        thing_to_execute.execute
      end
    end

    thing_to_execute.should have_received(:execute).once
  end

  it "treats different groups of params independently" do
    # Prevents a bug where we overwrite the uniqueness key
    # when we were doing a get(key) == hash check instead of
    # using the hash as part of the unique identifier

    2.times do
      described_class.do(name: "mycheck", params: {foo: "bar"}) do
        thing_to_execute.execute
      end
      described_class.do(name: "mycheck", params: {baz: "quux"}) do
        thing_to_execute.execute
      end
      described_class.do(name: "mycheck", params: {foo: "bar"}) do
        thing_to_execute.execute
      end
    end

    thing_to_execute.should have_received(:execute).twice
  end

  it "executes again after the time period passes" do
    described_class.do(name: "mycheck", within: 60, params: params) do
      thing_to_execute.execute
    end

    Timecop.travel(DateTime.now + 61) do
      described_class.do(name: "mycheck", within: 60, params: params) do
        thing_to_execute.execute
      end
    end

    thing_to_execute.should have_received(:execute).twice
  end
end
