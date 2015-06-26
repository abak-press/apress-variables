# coding: utf-8
require File.expand_path("../../spec_helper", __FILE__)

describe Apress::Variables do

  class TestSource #раскоментировать базовый класс, когда источники будут вынесены в гем !!! < CoreSources::Base
    def self.value_as_string(params)
      "#{params[:field]}#{params[:object][:company_id]}"
    end
  end

  class TestVariable < Apress::Variables::Variable
  end

  class TestVariablesList < Apress::Variables::VariablesList
  end

  class ClassA < Object
  end

  class ClassB < Object
  end

  class ClassC < Object
  end

  class TestList < Apress::Variables::List

    protected

    def self.variables_list
      [
        {
          :id            => 'company_id',
          :desc          => 'ID компании',
          :source_proc   => ->(params, args) { params.fetch(:company_id).to_s }
        },
        {
          :id            => 'int_variable',
          :desc          => 'int_variable',
          :classes       => :all,
          :source_proc   => ->(params, args) { '' },
          :type          => :integer
        },
        {
          :id            => 'test_variable',
          :desc          => 'test_variable1',
          :classes       => [ClassA, ClassB],
          :groups        => [:group1, :group2],
          :source_class  => TestSource,
          :source_params => {:field => :test_field}
        },
        {
          :id            => 'variable_redirect',
          :desc          => 'redirect variable',
          :classes       => [ClassA],
          :groups        => [:group1],
          :source_proc   => ->(params, args) { params.fetch(:company_id).to_s }
        },
        {
          :id            => 'variable2_redirect',
          :desc          => 'redirect 2 variable',
          :classes       => ['ClassA'],
          :groups        => ['group1'],
          :source_proc   => ->(params, args) { params.fetch(:company_id).to_s }
        },
        {
          :id            => 'with_name',
          :name          => 'NAME',
          :classes       => [ClassB],
          :groups        => [:group2],
          :source_proc   => ->(params, args) { params.fetch(:company_id).to_s }
        },
        {
          :id            => 'without_name',
          :classes       => ['sdfsdfsdf'],
          :groups        => ['dsgsdgdsgds'],
          :source_proc   => ->(params, args) { params.fetch(:company_id).to_s }
        },
        {
          :id            => 'variable_with_params',
          :desc          => 'variable_with_params',
          :classes       => [ClassB],
          :groups        => [:group2],
          :source_proc   => ->(params, args) { "#{params.fetch(:company_id)}#{args.join('_')}" }
        },
        {
          :id            => 'variable_without_class_and_proc',
          :desc          => 'variable_without_class_and_proc',
          :classes       => [ClassC],
          :groups        => [:group3],
        }
      ]
    end

    def self.variables_list_class
      TestVariablesList
    end

    def self.variable_class
      TestVariable
    end
  end

  class TestParser < Apress::Variables::Parser
    def self.list_class
      TestList
    end
  end

  let(:company_id) { rand(3434234) }
  let(:field) { rand(234234) }
  let(:params) { [1,4,'s',5,6] }

  context 'List' do
    context '.all' do
      it 'returns a list of all the variables' do
        expect(TestList.all.size).to eq TestList.variables_list.size
      end

      it 'returns a list of the correct type' do
        expect(TestList.all).to be_an_instance_of TestVariablesList
      end

      it 'returns a variable of the correct type' do
        expect(TestList.all.first).to be_an_instance_of TestVariable
      end

      it 'returns a correct variable' do
        expect(TestList.all.first.id).to eq TestList.variables_list.first[:id]
      end

      it 'indicates a variable number' do
        TestList.variables_list.each_with_index { |_, index| expect(TestList.all[index].oid).to eq index }
      end
    end

    context '.find_by_id' do
      let(:variable) { TestList.all[rand(TestList.all.size)] }

      it 'returns variable by id' do
        expect(TestList.find_by_id(variable.id)).to be variable
      end

      it 'returns nil if it is not found' do
        expect(TestList.find_by_id('sadfasdasfasf')).to be_nil
      end
    end

    context '.for_class' do
      it 'returns correct list of variables when searching for class' do
        expect(TestList.all.for_class(ClassA).size).to eq 5
      end

      it 'return variables suitable for all classes' do
        expect(TestList.all.for_class('sfsdfs').size).to eq 2
      end

      it 'return correct list of variables when searching by class name' do
        expect(TestList.all.for_class('ClassA').size).to eq 5
      end

      it 'return correct list of variables if the input argument array' do
        expect(TestList.all.for_class([ClassA, ClassB]).size).to eq 7
      end

      it 'returns a list of the correct type' do
        expect(TestList.all.for_class('ClassA')).to be_a TestVariablesList
      end
    end

    context '.for_group' do
      it 'returns correct list of variables when searching by group as symbol' do
        expect(TestList.all.for_group(:group1).size).to eq 5
      end

      it 'return variables suitable for all groups' do
        expect(TestList.all.for_group('sfsdfs').size).to eq 2
      end

      it 'return correct list of variables when searching by group as string' do
        expect(TestList.all.for_group('group1').size).to eq 5
      end

      it 'return correct list of variables if the input argument array' do
        expect(TestList.all.for_group(['group1', 'group2']).size).to eq 7
      end

      it 'returns a list of the correct type' do
        expect(TestList.all.for_group('group1')).to be_a TestVariablesList
      end
    end

    context 'protected methods' do
      it 'available method variable_class, returns class variable' do
        expect(TestList.send(:variable_class)).to be TestVariable
      end

      it 'available method variables_list_class, returns a list of class' do
        expect(TestList.send(:variables_list_class)).to be TestVariablesList
      end
    end

    it 'variables_list method throws an exception' do
      expect { Apress::Variables::List.send(:variables_list) }.to raise_error(NotImplementedError)
    end
  end

  context 'VariablesList' do
    let(:all_variables_list) { TestList.all }

    context '#redirects' do
      it 'returns only redirects' do
        expect(all_variables_list.redirects.size).to eq all_variables_list.count(&:redirect?)
      end

      it 'returns a list of the correct type' do
        expect(all_variables_list.redirects).to be_an_instance_of TestVariablesList
      end

      it 'returns a variable of the correct type' do
        expect(all_variables_list.redirects.first).to be_an_instance_of TestVariable
      end

      it 'returns a correct variable' do
        expect(all_variables_list.redirects.first).to be all_variables_list.find(&:redirect?)
      end
    end

    context '#variables' do
      it 'returns only redirects' do
        expect(all_variables_list.variables.size).to eq all_variables_list.count { |v| !v.redirect? }
      end

      it 'returns a list of the correct type' do
        expect(all_variables_list.variables).to be_an_instance_of TestVariablesList
      end

      it 'returns a variable of the correct type' do
        expect(all_variables_list.variables.first).to be_an_instance_of TestVariable
      end

      it 'returns a correct variable' do
        expect(all_variables_list.variables.first).to be all_variables_list.find { |v| !v.redirect? }
      end
    end
  end

  context 'Variable' do
    let(:variable) do
      {
        :id => :sdfsdf,
        :name => 'dsfsdgsd',
        :desc => 'sadasdasd',
        :source_class => 'source_class',
        :source_params => 'soucre_params',
        :source_proc => 'source_proc',
        :type => :integer
      }
    end

    let(:params) { {:company_id => company_id, :view_context => 'view'} }
    let(:args) { ['params', 1] }

    it 'constructor correctly handles parameters.' do
      variable.each { |key, _| expect(Apress::Variables::Variable.new(variable)[key]).to eq variable[key] }
    end

    context '#pretty_name' do
      let(:with_name) { TestList.find_by_id(:with_name) }
      let(:without_name) { TestList.find_by_id(:without_name) }

      it 'returns the name of the variable, if specified' do
        expect(with_name.pretty_name).to be with_name.name
      end

      it 'returns the id of the variable, if not specified' do
        expect(without_name.pretty_name).to be without_name.id
      end
    end

    context '#redirect?' do
      let(:redirect_var) { TestList.find_by_id(:variable_redirect) }
      let(:no_redirect_var) { TestList.find_by_id(:test_variable) }

      it 'returns true for variable - redirect' do
        expect(redirect_var).to be_redirect
      end

      it 'returns false for variable - no redirect' do
        expect(no_redirect_var).to_not be_redirect
      end
    end

    context '#value' do
      let(:variable_with_source) { TestList.find_by_id(:test_variable) }
      let(:variable_with_proc) { TestList.find_by_id(:variable_redirect) }
      let(:variable_without_class_and_proc) { TestList.find_by_id(:variable_without_class_and_proc) }
      let(:int_variable) { TestList.find_by_id(:int_variable) }

      it 'correctly computes the value of the variable' do
        expect(variable_with_source).to receive(:raw_value).with(params, args).ordered
        expect(variable_with_source).to receive(:format).ordered
        variable_with_source.value(params, args)
      end

      it 'args not reguired argument' do
        expect(variable_with_source).to receive(:raw_value).with(params, []).ordered
        expect(variable_with_source).to receive(:format).ordered
        variable_with_source.value(params)
      end

      it 'invokes the source, if source class specified' do
        expect(TestSource).to receive(:value_as_string).and_return("returning #{company_id}")
        expect(variable_with_source.value(params, args)).to eq "returning #{company_id}"
      end

      context 'if the class - the source is not specified and the specified proc' do
        it 'call proc' do
          expect(variable_with_proc.source_proc)
            .to receive(:call)
            .with({:company_id => company_id, :view_context => 'view'}, ['params', 1])
            .and_return("proc returning #{company_id}")

          expect(variable_with_proc.value(params, args)).to eq "proc returning #{company_id}"
        end

        it 'compute proc with method proc_value' do
          expect(variable_with_proc)
            .to receive(:proc_value)
            .with(variable_with_proc.source_proc, params, args)
            .and_return("proc returning #{company_id}")

          expect(variable_with_proc.value(params, args)).to eq "proc returning #{company_id}"
        end
      end

      context 'when class and proc not specified' do
        it { expect { variable_without_class_and_proc.value(params, args) }.to raise_error(ArgumentError) }
      end

      it 'correctly format the value of a variable, if you specify the type Integer' do
        expect(int_variable.value(params, args)).to eq '0'
      end

      it 'correctly format the value of a variable, if variable type not specified' do
        int_variable2 = int_variable.clone
        int_variable2.delete(:type)
        expect(int_variable2.value(params, args)).to eq ''
      end
    end
  end

  context 'integration' do
    it 'unknown variable is not replace' do
      expect(TestParser.replace_variables('content {unknown_var} test', :company_id => company_id))
        .to eq "content {unknown_var} test"
    end

    it 'variable with source - lambda' do
      expect(TestParser.replace_variables('content {company_id} test', :company_id => company_id))
        .to eq "content #{company_id} test"
    end

    it 'variable with source - class' do
      expect(TestParser.replace_variables('content {test_variable} test', :company_id => company_id))
        .to eq "content test_field#{company_id} test"
    end

    it 'typed variable' do
      expect(TestParser.replace_variables('content {int_variable} test', :company_id => company_id))
        .to eq "content #{0} test"
    end

    it 'several variables' do
      expect(TestParser.replace_variables('content {int_variable} test {test_variable}', :company_id => company_id))
        .to eq "content #{0} test test_field#{company_id}"
    end

    it 'variable with args' do
      expect(TestParser.replace_variables("content {variable_with_params(#{params.join(', ')})} test", :company_id => company_id))
        .to eq "content #{company_id}#{params.join('_')} test"
    end
  end
end