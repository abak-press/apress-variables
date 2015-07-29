# coding: utf-8
require 'spec_helper'

class TestSource
  def self.value_as_string(params)
    "test_source_#{params[:field]}_#{params[:object][:company_id]}"
  end
end

describe Apress::Variables::Variable do
  let(:id) { :id }
  let(:name) { nil }
  let(:desc) { nil }
  let(:type) { nil }
  let(:default) { nil }
  let(:rate) { nil }
  let(:max_rate) { nil }
  let(:source_class) { nil }
  let(:source_params) { nil }
  let(:source_proc) { nil }
  let(:groups) { nil }
  let(:classes) { nil }
  let(:options) { nil }

  let(:variable) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = id
      v.name = name
      v.desc = desc
      v.type = type
      v.default = default
      v.rate = rate
      v.max_rate = max_rate
      v.source_class = source_class
      v.source_params = source_params
      v.source_proc = source_proc
      v.groups = groups
      v.classes = classes
      v.options = options
    end
  end

  let(:company_id) { rand(234) }

  context "#pretty_name" do
    context "when variable has name" do
      let(:name) { "variable name" }

      it "returns the name of the variable" do
        expect(variable.pretty_name).to eq "variable name"
      end
    end

    context "when variable has name" do
      let(:name) { nil }

      it "returns the id of the variable" do
        expect(variable.pretty_name).to eq "id"
      end
    end
  end

  context '#value' do
    let(:params) { {:company_id => company_id} }
    let(:args) { [1, '2', 3] }

    context "when source_class specified" do
      let(:source_class) { TestSource }
      let(:source_params) { {:field => 'field_name'} }

      it "invokes the source, if source class specified" do
        expect(TestSource).to receive(:value_as_string).
                                with(:field => 'field_name', :object => params).
                                and_call_original
        expect(variable.value(params, args)).to eq "test_source_field_name_#{company_id}"
      end

      it "args not reguired argument" do
        expect(variable.value(params)).to eq "test_source_field_name_#{company_id}"
      end
    end

    context "when source_class not specified and source_proc specified" do
      let(:source_proc) { ->(params, arg) { "proc returning #{params[:company_id]} #{args}" } }

      it "invokes the source, if source class specified" do
        expect(source_proc).to receive(:call).with(params, args).and_call_original
        expect(variable.value(params, args)).to eq "proc returning #{company_id} #{args}"
      end
    end

    context "when source class and proc not specified" do
      it { expect { variable.value(params, args) }.to raise_error(ArgumentError) }
    end

    context "when check value formating" do
      let(:source_proc) { ->(params, arg) { nil } }

      context "when type not specified" do
        context "when default specified" do
          let(:default) { 13 }

          it { expect(variable.value(params, args)).to eq "13" }
        end

        context "when default not specified" do
          it { expect(variable.value(params, args)).to eq "" }
        end
      end

      context "when type Integer" do
        let(:type) { :integer }

        it { expect(variable.value(params, args)).to eq "0" }
      end
    end

    context "when check rate" do
      let(:source_proc) { ->(params, arg) { "5" } }

      context "when rate is specified" do
        let(:rate) { 10 }

        it { expect(variable.value(params, args)).to eq "50" }
      end
    end
  end

  context "when check options" do
    let(:options) { {:param1 => 1, :param2 => 2} }

    it { expect(variable.options).to eq options }
  end

  context "when check default context" do
    it { expect(variable.context).to eq Array.new }
  end

  context "#redirect?" do
    context "when variable - redirect" do
      let(:id) { "variable_redirect" }

      it { expect(variable).to be_redirect }
    end

    context "when variable - no redirect" do
      let(:id) { "simple_variable" }

      it { expect(variable).to_not be_redirect }
    end
  end

  context "#for_class?" do
    context "when classes not specified" do
      it { expect(variable.for_class?(:any_class)).to be true }
    end

    context "when classes specified" do
      context "when classes is :all symbol" do
        let(:classes) { :all }

        it { expect(variable.for_class?(:any_class)).to be true }
      end

      context "when classes is one custom class" do
        let(:classes) { :class }

        it { expect(variable.for_class?(:class)).to be true }
        it { expect(variable.for_class?([:class])).to be true }
        it { expect(variable.for_class?(:another_class)).to be false }
        it { expect(variable.for_class?([:another_class])).to be false }
        it { expect(variable.for_class?([:class, :another_class])).to be true }
      end

      context "when classes is array of custom classs" do
        let(:classes) { [:class1, :class2] }

        it { expect(variable.for_class?(:class1)).to be true }
        it { expect(variable.for_class?([:class1])).to be true }
        it { expect(variable.for_class?(:class2)).to be true }
        it { expect(variable.for_class?([:class2])).to be true }
        it { expect(variable.for_class?(:another_class)).to be false }
        it { expect(variable.for_class?([:another_class])).to be false }
        it { expect(variable.for_class?([:class1, :another_class])).to be true }
      end
    end
  end

  context "#for_group?" do
    context "when groups not specified" do
      it { expect(variable.for_group?(:any_group)).to be true }
    end

    context "when groups specified" do
      context "when groups is :all symbol" do
        let(:groups) { :all }

        it { expect(variable.for_group?(:any_group)).to be true }
      end

      context "when groups is one custom group" do
        let(:groups) { :group }

        it { expect(variable.for_group?(:group)).to be true }
        it { expect(variable.for_group?([:group])).to be true }
        it { expect(variable.for_group?(:another_group)).to be false }
        it { expect(variable.for_group?([:another_group])).to be false }
        it { expect(variable.for_group?([:group, :another_group])).to be true }
      end

      context "when groups is array of custom groups" do
        let(:groups) { [:group1, :group2] }

        it { expect(variable.for_group?(:group1)).to be true }
        it { expect(variable.for_group?([:group1])).to be true }
        it { expect(variable.for_group?(:group2)).to be true }
        it { expect(variable.for_group?([:group2])).to be true }
        it { expect(variable.for_group?(:another_group)).to be false }
        it { expect(variable.for_group?([:another_group])).to be false }
        it { expect(variable.for_group?([:group1, :another_group])).to be true }
      end
    end
  end
end