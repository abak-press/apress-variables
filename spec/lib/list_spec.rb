# coding: utf-8
require 'spec_helper'

describe Apress::Variables::List do
  let(:var) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var0
      v.desc = "duplicate id, duplicate context"
    end
  end

  let(:var0) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var0
      v.name = "name"
      v.desc = "desc"
      v.groups = ['group_2', :group]
    end
  end

  let(:var1) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var1
      v.context = ['user_id']
      v.classes = ['class_2', Object]
    end
  end

  let(:var2) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var2_redirect
      v.context = [:company_id, 'user_id']
      v.classes = :all
      v.groups = ['group_1']
    end
  end

  let(:var3) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var3_redirect
      v.context = [:company_id, 'user_id']
      v.classes = ['class_1']
    end
  end

  let(:var4) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var4
      v.context = [:company_id]
    end
  end

  let(:var5) do
    Apress::Variables::Variable.new.tap do |v|
      v.id = :var1
      v.desc = 'diplicate id, another context'
      v.context = ['another_id']
      v.classes = ['class_2', Object]
    end
  end

  let(:list) { Apress::Variables::List.new }

  let(:company_id) { rand(234) }

  before do
    list.add(var)
    list.add(var0)
    list.add(var1)
    list.add(var2)
    list.add(var3)
    list.add(var5)
  end

  it { expect(list).to be_a(Enumerable) }

  context "#find_by_id" do
    context "when variable not exists" do
      it { expect(list.find_by_id(:unknown_id)).to be_nil }
    end

    context "when variable exists" do
      context "when find by sym" do
        it { expect(list.find_by_id(:var0)).to eq var0 }
      end

      context "when find by string" do
        it { expect(list.find_by_id('var0')).to eq var0 }
      end

      context "when exists few variable with equal id and other context, return first" do
        it { expect(list.find_by_id('var1')).to eq var1 }
      end
    end
  end

  context "#for_context" do
    before do
      list.add(var4)
    end

    it { expect(list.for_context(['user_id'])).to be_a(described_class) }

    it { expect(list.for_context(['user_id']).to_a).to eq [var0, var1] }
    it { expect(list.for_context([:user_id]).to_a).to eq [var0, var1] }
    it { expect(list.for_context([:user_id, 'company_id']).to_a).to match_array([var0, var1, var2, var3, var4]) }
    it do
      expect(list.for_context([:unknown_param, :user_id, 'company_id']).to_a).
        to match_array([var0, var1, var2, var3, var4])
    end

    it { expect(list.for_context([:unknown_param]).to_a).to eq [var0] }

    it { expect(list.for_context(['company_id']).to_a).to eq [var0, var4] }

    it { expect(list.for_context(:company_id => 1).to_a).to eq [var0, var4] }
  end

  context "#redirects" do
    it { expect(list.redirects).to be_a(described_class) }
    it { expect(list.redirects.to_a).to match_array([var3, var2]) }
  end

  context "#variables" do
    it { expect(list.variables).to be_a(described_class) }
    it { expect(list.variables.to_a).to match_array([var0, var1, var5]) }
  end

  context "#for_class" do
    it { expect(list.for_class(String)).to be_a(described_class) }
    it { expect(list.for_class(String).to_a).to match_array([var0, var2]) }

    it { expect(list.for_class('class_1').to_a).to match_array([var0, var2, var3]) }
    it { expect(list.for_class(:class_1).to_a).to match_array([var0, var2, var3]) }

    it { expect(list.for_class('class_2').to_a).to match_array([var0, var1, var2, var5]) }
    it { expect(list.for_class(%w(class_1 class_2)).to_a).to match_array([var0, var1, var2, var3, var5]) }
  end

  context "#for_group" do
    it { expect(list.for_group('custom_group')).to be_a(described_class) }
    it { expect(list.for_group('custom_group').to_a).to match_array([var1, var3, var5]) }

    it { expect(list.for_group('group_1').to_a).to match_array([var1, var2, var3, var5]) }

    it { expect(list.for_group('group_2').to_a).to match_array([var0, var1, var3, var5]) }
    it { expect(list.for_group(:group_2).to_a).to match_array([var0, var1, var3, var5]) }

    it { expect(list.for_group(%w(group_1 group_2)).to_a).to match_array([var0, var1, var2, var3, var5]) }
  end

  context "#variable_class" do
    it { expect(list.variable_class).to be Apress::Variables::Variable }
  end

  context "#each_uniq_by_id" do
    it { expect(list.for_context([:user_id, :another_id]).to_a).to match_array([var0, var1, var5]) }
    it { expect(list.for_context([:user_id, :another_id]).uniq_by_id.to_a).to match_array([var0, var1]) }
  end

  context "when initialize with list" do
    it { expect(described_class.new([var2, var0]).to_a).to match_array([var0, var2]) }
  end
end