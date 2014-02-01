require 'spec_helper'

describe Listen::TCP::Listener do

  let(:host) { '10.0.0.0' }
  let(:port) { 4000 }

  subject { described_class.new("#{host}:#{port}", :recipient, options) }
  let(:options) { {} }
  let(:registry) { double(Celluloid::Registry, :[]= => true) }
  let(:supervisor) { double(Celluloid::SupervisionGroup, add: true, pool: true) }
  let(:record) { double(Listen::Record, terminate: true, build: true) }
  let(:silencer) { double(Listen::Silencer, terminate: true) }
  let(:adapter) { double(Listen::Adapter::Base) }
  let(:broadcaster) { double(Listen::TCP::Broadcaster) }
  let(:change_pool) { double(Listen::Change, terminate: true) }
  let(:change_pool_async) { double('ChangePoolAsync') }
  before {
    Celluloid::Registry.stub(:new) { registry }
    Celluloid::SupervisionGroup.stub(:run!) { supervisor }
    registry.stub(:[]).with(:silencer) { silencer }
    registry.stub(:[]).with(:adapter) { adapter }
    registry.stub(:[]).with(:record) { record }
    registry.stub(:[]).with(:change_pool) { change_pool }
    registry.stub(:[]).with(:broadcaster) { broadcaster }
  }

  describe '#initialize' do
    its(:mode) { should be :recipient }
    its(:host) { should eq host }
    its(:port) { should eq port }

    it 'raises on invalid mode' do
      expect do
        described_class.new(port, :foo)
      end.to raise_error ArgumentError
    end

    it 'raises on omitted target' do
      expect do
        described_class.new(nil, :recipient)
      end.to raise_error ArgumentError
    end
  end

  context 'when broadcaster' do
    subject { described_class.new(port, :broadcaster) }

    it { should be_a_broadcaster }
    it { should_not be_a_recipient }

    it 'does not force TCP adapter through options' do
      expect(subject.options).not_to include(force_tcp: true)
    end

    context 'when host is omitted' do
      its(:host) { should be_nil }
    end
  end

  context 'when recipient' do
    subject { described_class.new(port, :recipient) }

    it 'forces TCP adapter through options' do
      expect(subject.options).to include(force_tcp: true)
    end

    it { should_not be_a_broadcaster }
    it { should be_a_recipient }

    context 'when host is omitted' do
      its(:host) { should eq described_class::DEFAULT_HOST }
    end
  end

  # TODO: Spec all the things

end
