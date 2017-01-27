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
      v.id = :variable_one
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
      v.id = :var_three
      v.source_proc = ->(params, args) { "var_three_#{args.join}" }
    end
  end

  let(:var_with_error) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var_with_error
      v.source_proc = ->(params, args) { raise Apress::Variables::UnknownVariableError }
    end
  end

  let(:var_with_colon) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = "test:var"
      v.source_proc = ->(params, args) { 'test_val' }
    end
  end

  let(:list) { Apress::Variables::List.new }
  let(:company_id) { rand(234) }
  let(:options) { {} }
  let(:parser) { described_class.new(list, options) }
  let(:args) { [1, 4, 's', 5, 6] }
  let(:templates) do
    [
      "content {int_variable} test {variable_one} a",
      "content {variable_with_args(#{args.join(', ')})} test",
      "content {var_three({variable_with_args(#{args.join(', ')})})} test",
      "content {var_three({variable_one})} test",
      "content {var_three({variable_with_args(#{args.join(', ')})}sometext)} test",
      "content {variable_with_args(c, {variable_one})} test"
    ]
  end

  before do
    list.add(var0)
    list.add(var1)
    list.add(var2)
    list.add(var3)
    list.add(var_with_error)
    list.add(var_with_colon)
  end

  context "when template is nil" do
    it { expect(parser.replace_variables(nil, company_id: company_id)).to be_empty }
    it { expect(parser.replace_variables(nil, company_id: company_id).html_safe?).to be true }
  end

  it "several variables" do
    expect(parser.replace_variables(templates[0], company_id: company_id))
      .to eq "content #{0} test a#{company_id}b a"
  end

  it "variable with args" do
    expect(parser.replace_variables(templates[1], company_id: company_id))
      .to eq "content #{company_id}#{args.join('_')} test"
  end

  it "nested variable with args" do
    expect(parser.replace_variables(templates[2], company_id: company_id))
      .to eq "content var_three_#{company_id}#{args.join('_')} test"
  end

  it "nested variable without args" do
    expect(parser.replace_variables(templates[3], company_id: company_id))
      .to eq "content var_three_a#{company_id}b test"
  end

  it "nested variable with args" do
    expect(parser.replace_variables(templates[4], company_id: company_id))
      .to eq "content var_three_#{company_id}#{args.join('_')}sometext test"
  end

  it "nested variable with multi args" do
    expect(parser.replace_variables(templates[5], company_id: company_id))
      .to eq "content #{company_id}c_a#{company_id}b test"
  end

  it "several variables with args" do
    expect(parser.replace_variables(templates.join(' '), company_id: company_id))
      .to eq(templates.map { |text| parser.replace_variables(text, company_id: company_id) }.join(' '))
  end

  context 'when have code in braces' do
    context 'when not variable' do
      let(:template) { '{some script/code here}' }

      it 'should return safe text' do
        expect(parser.replace_variables(template, company_id: company_id)).to eq template
      end
    end

    context 'when nested braces' do
      context 'when include variable' do
        it 'should replace nested variable' do
          expect(parser.replace_variables('{some script/code {int_variable} here}', company_id: company_id))
            .to eq '{some script/code 0 here}'
        end
      end

      context 'when include non variable code' do
        let(:template) { '{some script/code {some script/code again} here}' }

        it 'should return safe text' do
          expect(parser.replace_variables(template, company_id: company_id)).to eq template
        end
      end
    end
  end

  context "when unknown variable" do
    context "when silent = true (default)" do
      it "not replace unknown variable" do
        expect(parser.replace_variables("content {int_variable} {unknown_var} test", company_id: company_id))
          .to eq "content 0 {unknown_var} test"
      end

      it "nothing replaced. returns the original string" do
        expect(parser.replace_variables("content {var_three({variable_unknown})} test", company_id: company_id))
          .to eq "content {var_three({variable_unknown})} test"
      end

      it "replace simple variable in unknown" do
        expect(parser.replace_variables("content {variable_unknown({var_three(#{args.join(',')})})} test",
                                        company_id: company_id))
          .to eq "content {variable_unknown(var_three_#{args.join})} test"
      end
    end

    context "when variable raise UnknownVariableError" do
      it "rescue error when parse" do
        expect(parser.replace_variables("content {var_with_error} test", {})).to eq "content {var_with_error} test"
      end

      it "not replace only variable with error" do
        expect(parser.replace_variables("content {int_variable} {var_with_error(some_arg)} test", {}))
          .to eq "content 0 {var_with_error(some_arg)} test"
      end
    end

    context "when silent = false" do
      let(:options) { {silent: false} }

      it "nothing replaced. raise UnknownVariableError" do
        expect do
          parser.replace_variables("content {int_variable} {unknown_var} test", company_id: company_id)
        end.to raise_error Apress::Variables::UnknownVariableError
      end

      context "when content contains CSS definitions" do
        it "ignores CSS styles" do
          expect do
            parser.replace_variables("test {variable_with_args({test:var})} {test:var} {color:red;} {color : #12} test",
                                     company_id: company_id)
          end.not_to raise_error Apress::Variables::UnknownVariableError
        end

        it "replaces variables only and ignores CSS styles" do
          expect(
            parser.replace_variables("test {variable_with_args({test:var})} {test:var} {color:red;} {color : #12} test",
                                     company_id: company_id)
          ).to eq "test #{company_id}test_val test_val {color:red;} {color : #12} test"
        end
      end

      context "when variable raise UnknownVariableError" do
        it "raise error when parse" do
          expect { parser.replace_variables("content {var_with_error(some_arg)} test", {}) }
            .to raise_error(Apress::Variables::UnknownVariableError)
            .with_message("Variable var_with_error with args some_arg not found in list")
        end
      end
    end
  end

  describe "#extract_variables" do
    context "when string contains nested variables with argument" do
      let(:str) do
        "р1 {color:red;} Consectetur, {aaa:bbb({ccc:ddd(lol, olo)})}? adipiscing elit! var a = {isAdmin : true}"
      end

      it "returns all variables id" do
        expect(described_class.extract_variables(str)).to match_array ["aaa:bbb", "ccc:ddd"]
      end
    end

    context "when string contains simple variables" do
      let(:str) { "Lorem ipsum dolor sit amet. Consectetur, {aaa:bbb} {ccc:ddd(lol)})? adipiscing elit!" }

      it "returns all variables id" do
        expect(described_class.extract_variables(str)).to match_array ["aaa:bbb", "ccc:ddd"]
      end
    end
  end
end
