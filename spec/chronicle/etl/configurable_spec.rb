require 'spec_helper'

RSpec.describe Chronicle::ETL::Configurable do
  let(:basic) do
    Class.new do
      include Chronicle::ETL::Configurable
      
      setting :foo
      
      def initialize(options={})
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

  describe "Basic use" do
    before do
      stub_const("BasicClass", basic)
      stub_const("InheritedFromBasicClass", inherited)
      stub_const("InheritedInheritedFromBasicClass", inherited_inherited)
    end

    it "can be configured" do
      c = BasicClass.new(foo: 'bar')
      expect(c.config.foo).to eql('bar')
    end

    it "can inherit settings from superclass" do
      c = InheritedFromBasicClass.new(foo: 'bar')
      expect(c.config.foo).to eql('bar')
    end

    it "can inherit settings from superclass's superclass" do
      c = InheritedInheritedFromBasicClass.new(foo: 'bar')
      expect(c.config.foo).to eql('bar')
    end

    it "does not configure unrecognized settings" do
      expect { BasicClass.new(arbitrary_setting: 'bar') }.to raise_error(Chronicle::ETL::ConfigurationError)
    end
  end

  describe "Required settings" do
    before do
      stub_const("RequiredSettingClass", with_required)
      stub_const("RequiredSettingSubclass", Class.new(RequiredSettingClass) { setting(:req, required: false)})
    end

    it "raises an exception if missing an option" do
      expect { RequiredSettingClass.new(foo: 'bar') }.to raise_error(Chronicle::ETL::ConfigurationError)
    end

    it "can override parent class required setting" do
      expect { RequiredSettingSubclass.new(foo: 'bar') }.to_not raise_error
    end
  end

  describe "Default values" do
    before do
      stub_const("DefaultSettingClass", with_default)
      stub_const("DefaultSettingSubclass", Class.new(DefaultSettingClass) { setting(:def, default: 'new value')})
    end

    it "has a default value set" do
      c = DefaultSettingClass.new(foo: 'bar')
      expect(c.config.def).to eql('default value')
    end

    it "can have a default value overriden by a subclass" do
      c = DefaultSettingSubclass.new(foo: 'bar')
      expect(c.config.def).to eql('new value')
    end
  end
end
