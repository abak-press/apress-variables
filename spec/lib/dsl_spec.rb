# coding: utf-8
# rubocop:disable SingleSpaceBeforeFirstArg
require 'spec_helper'

Apress::Variables.list.add_variables do
  context :view_context, :company

  variable do
    id            'company1'
    name          'company1_name'
    desc          'company1_desc'

    type          :integer
    default       5
    rate          10
    max_rate      100
    options       ({custom_option: 1})

    source_class  Object
    source_params ({test_params: 1})
    source_proc   ->() { 'test' }

    groups        1, 2, 3
    classes       [3, 2, 1]
  end

  variable do
    id            'company2'
  end

  variable do
    id            'company3'
    context       :custom_context_param
  end

  context :custom_context_param
  variable do
    id            'company4'
  end
end

describe Apress::Variables::Dsl do
  let(:list) { Apress::Variables.list }

  it { expect(list.to_a.size).to eq 4 }

  it { expect(list.for_context([:view_context, :company]).to_a.size).to eq 2 }
  it { expect(list.for_context([:custom_context_param]).to_a.size).to eq 2 }

  it 'correctly set the parameters of the variable' do
    var = list.for_context([:view_context, :company]).to_a.first

    expect(var.id).to eq 'company1'
    expect(var.name).to eq 'company1_name'
    expect(var.desc).to eq 'company1_desc'
    expect(var.type).to eq :integer
    expect(var.default).to eq 5
    expect(var.rate).to eq 10
    expect(var.max_rate).to eq 100
    expect(var.options).to eq ({custom_option: 1})
    expect(var.source_class).to eq Object
    expect(var.source_params).to eq ({test_params: 1})
    expect(var.source_proc.call).to eq 'test'
    expect(var.groups).to eq [1, 2, 3]
    expect(var.classes).to eq [3, 2, 1]

    var = list.for_context([:view_context, :company]).to_a.second
    expect(var.id).to eq 'company2'
  end

  context 'when check custom context' do
    it { expect(list.for_context([:custom_context_param]).to_a.first.id).to eq 'company3' }
    it { expect(list.for_context([:custom_context_param]).to_a.second.id).to eq 'company4' }
  end
end