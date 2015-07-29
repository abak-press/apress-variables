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

  let(:list) { Apress::Variables::List.new }
  let(:company_id) { rand(234) }
  let(:parser) { described_class.new(list) }
  let(:args) { [1, 4, 's', 5, 6] }

  before do
    list.add(var0)
    list.add(var1)
    list.add(var2)
  end

  it "unknown variable is not replace" do
    expect(parser.replace_variables("content {unknown_var} test", company_id: company_id))
      .to eq "content {unknown_var} test"
  end

  it "several variables" do
    expect(parser.replace_variables("content {int_variable} test {variable1} {unknown_var} a", company_id: company_id))
      .to eq "content #{0} test a#{company_id}b {unknown_var} a"
  end

  it "variable with args" do
    expect(parser.replace_variables("content {variable_with_args(#{args.join(', ')})} test", company_id: company_id))
      .to eq "content #{company_id}#{args.join('_')} test"
  end
end