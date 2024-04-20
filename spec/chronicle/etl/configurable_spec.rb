require 'spec_helper'

RSpec.describe Chronicle::ETL::Configurable do
  let(:basic) do
    Class.new do
      include Chronicle::ETL::Configurable

      setting :foo

      def initialize(options = {})
        apply_options(options)
      end
    end
  end

  let(:inherited) do
    Class.new(basic)
  end

  let(:inherited_inherited) do
    Class.new(inherited)
  end

  let(:with_required) do
    Class.new(basic) do
      setting :req, required: true
    end
  end

  let(:with_default) do
    Class.new(basic) do
      setting :def, default: 'default value'
    end
  end

  let(:with_type_time) do
    Class.new(basic) do
      setting :since, type: :time
    end
  end

  describe 'Basic use' do
    before do
      stub_const('BasicClass', basic)
      stub_const('InheritedFromBasicClass', inherited)
      stub_const('InheritedInheritedFromBasicClass', inherited_inherited)
    end

    it 'can be configured' do
      c = BasicClass.new(foo: 'bar')
      expect(c.config.foo).to eql('bar')
    end

    it 'can inherit settings from superclass' do
      c = InheritedFromBasicClass.new(foo: 'bar')
      expect(c.config.foo).to eql('bar')
    end

    it "can inherit settings from superclass's superclass" do
      c = InheritedInheritedFromBasicClass.new(foo: 'bar')
      expect(c.config.foo).to eql('bar')
    end

    it 'does not configure unrecognized settings' do
      c = BasicClass.new(arbitrary_setting: 'bar')
      expect(c.config.arbitrary_setting).to be_nil
    end
  end

  describe 'Required settings' do
    before do
      stub_const('RequiredSettingClass', with_required)
      stub_const('RequiredSettingSubclass', Class.new(RequiredSettingClass) { setting(:req, required: false) })
    end

    it 'raises an exception if missing an option' do
      expect { RequiredSettingClass.new(foo: 'bar') }.to raise_error(Chronicle::ETL::ConnectorConfigurationError)
    end

    it 'can override parent class required setting' do
      expect { RequiredSettingSubclass.new(foo: 'bar') }.to_not raise_error
    end
  end

  describe 'Default values' do
    before do
      stub_const('DefaultSettingClass', with_default)
      stub_const('DefaultSettingSubclass', Class.new(DefaultSettingClass) { setting(:def, default: 'new value') })
    end

    it 'has a default value set' do
      c = DefaultSettingClass.new(foo: 'bar')
      expect(c.config.def).to eql('default value')
    end

    it 'can have a default value overriden by a subclass' do
      c = DefaultSettingSubclass.new(foo: 'bar')
      expect(c.config.def).to eql('new value')
    end
  end

  describe 'Typed settings' do
    context 'for type time' do
      before do
        stub_const('TypedSettingClass', with_type_time)
      end

      it 'does not change values that do not have to be coerced' do
        c = TypedSettingClass.new(since: Time.new(2022, 2, 24))
        expect(c.config.since).to be_a_kind_of(Time)
        expect(c.config.since.to_date.iso8601).to eq('2022-02-24')
      end

      it 'coerces settings of type: time into Time objects' do
        c = TypedSettingClass.new(since: '2022-02-24 14:00-0500')
        expect(c.config.since).to be_a_kind_of(Time)
        expect(c.config.since.iso8601).to eq('2022-02-24T14:00:00-05:00')
      end

      it 'coerces Date values into Time objects' do
        c = TypedSettingClass.new(since: Date.new(2022, 4, 1))
        expect(c.config.since).to be_a_kind_of(Time)
        expect(c.config.since.iso8601).to eq('2022-04-01T00:00:00+00:00')
      end

      it 'interprets fuzzy time ranges correctly' do
        c = TypedSettingClass.new(since: '1d3h')
        expected_time = Time.now.to_i - 86_400 - 10_800
        expect(c.config.since).to be_a_kind_of(Time)
        expect(c.config.since.to_i).to be_within(100).of(expected_time)
      end

      it "returns an error when a range can't be parsed" do
        expect { TypedSettingClass.new(since: 'foo') }.to raise_error(Chronicle::ETL::ConnectorConfigurationError)
      end
    end
  end
end
