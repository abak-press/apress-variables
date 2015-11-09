# coding: utf-8
require 'spec_helper'

describe Apress::Variables::Parser do
  let(:var0) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :int_variable
      v.type = :integer
      v.source_proc = ->(params, args) { '' }
    end
  end

  let(:var1) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :variable1
      v.source_proc = ->(params, args) { "a#{params[:company_id]}b" }
    end
  end

  let(:var2) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :variable_with_args
      v.source_proc = ->(params, args) { "#{params[:company_id]}#{args.join('_')}" }
    end
  end

  let(:var3) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var3
      v.source_proc = ->(params, args) { "var3_#{args.join}" }
    end
  end

  let(:list) { Apress::Variables::List.new }
  let(:company_id) { rand(234) }
  let(:options) { {} }
  let(:parser) { described_class.new(list, options) }
  let(:args) { [1, 4, 's', 5, 6] }

  before do
    list.add(var0)
    list.add(var1)
    list.add(var2)
    list.add(var3)
  end

  context "when template is nil" do
    it { expect(parser.replace_variables(nil, company_id: company_id)).to be_empty }
    it { expect(parser.replace_variables(nil, company_id: company_id).html_safe?).to be true }
  end

  it "several variables" do
    expect(parser.replace_variables("content {int_variable} test {variable1} a", company_id: company_id))
      .to eq "content #{0} test a#{company_id}b a"
  end

  it "variable with args" do
    expect(parser.replace_variables("content {variable_with_args(#{args.join(', ')})} test", company_id: company_id))
      .to eq "content #{company_id}#{args.join('_')} test"
  end

  it "variable with args" do
    expect(parser.replace_variables(
                   "content {var3({variable_with_args(#{args.join(', ')})})} test",
                   company_id: company_id
    ))
    .to eq "content var3_#{company_id}#{args.join('_')} test"
  end

  it "nested variable without args" do
    expect(parser.replace_variables("content {var3({variable1})} test", company_id: company_id))
    .to eq "content var3_a#{company_id}b test"
  end

  it "nested variable with args" do
    expect(parser.replace_variables(
                   "content {var3({variable_with_args(#{args.join(', ')})}sometext)} test",
                   company_id: company_id
    ))
    .to eq "content var3_#{company_id}#{args.join('_')}sometext test"
  end

  it "nested variable without args" do
    expect(parser.replace_variables("content {var3({variable1})} test", company_id: company_id))
    .to eq "content var3_a#{company_id}b test"
  end

  context "when unknown variable" do
    context "when silent = true (default)" do
      it "nothing replaced. returns the original string" do
        expect(parser.replace_variables("content {int_variable} {unknown_var} test", company_id: company_id))
        .to eq "content {int_variable} {unknown_var} test"
      end

      it "nothing replaced. returns the original string" do
        expect(parser.replace_variables("content {var3({variable11})} test", company_id: company_id))
        .to eq "content {var3({variable11})} test"
      end
    end

    context "when silent = false" do
      let(:options) { {silent: false} }

      it "nothing replaced. raise UnknownVariableError" do
        expect do
          parser.replace_variables("content {int_variable} {unknown_var} test", company_id: company_id)
        end.to raise_error Apress::Variables::UnknownVariableError
      end
    end
  end
end