# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Arguments' do
  before(:all) do
    DummyModel.create!(name: 'Dummy1', active: false, number: 1)
    DummyModel.create!(name: 'Dummy2', active: true, number: 1)
    DummyModel.create!(name: 'Dummy3', active: true, number: 2)
  end

  describe '.query' do
    context 'when defining argument as required and default' do
      subject do
        DummyModels::Query.query(:by_name, 'desc',
          { name: { type: String, optional: true, default: 'Dummy1' } },
          ->(name:) { scope.where(name: name) })
      end

      it 'raises an error because you cannot define default and required for an argument' do
        expect { subject }.to raise_error(ArgumentError, "Optional and Default params can't be present together: [:name]")
      end
    end

    context 'when passing no args to query with args' do
      subject { DummyModels::Query.by_name }

      it 'raises an error because args are not provided' do
        expect { subject }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end

    context 'when missing required argument' do
      subject { DummyModels::Query.by_name(other_arg: 'example') }

      it 'raises an error indicating name param is missing' do
        expect { subject }.to raise_error(ArgumentError, 'Params missing: [:name]')
      end
    end

    context 'when argument given wrong type' do
      subject { DummyModels::Query.by_name(name: 10) }

      it 'raises an error indicating name param is missing' do
        expect { subject }.to raise_error(ArgumentError, ':name must be of type String')
      end
    end

    context 'when passing boolean, string and integer' do
      subject { DummyModels::Query.all_args(active: false, name: 'Dummy1', number: 1) }

      it 'returns the dummy model that matches criteria' do
        expect(subject).to include(DummyModel.find_by(name: 'Dummy1'))
      end
    end

    context "when you don't pass an argument that has default" do
      subject { DummyModels::Query.example_with_default(number: 1) }

      it 'returns Dummy2 because defaults active to false' do
        expect(subject).to include(DummyModel.find_by(name: 'Dummy2'))
      end

      context "when you don't pass an argument that has optional == true" do
        it 'returns Dummy2, query still executes because name was optional' do
          expect(subject).to include(DummyModel.find_by(name: 'Dummy2'))
        end
      end
    end
  end
end
