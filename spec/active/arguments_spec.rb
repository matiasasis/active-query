# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Arguments' do
  let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }
  let!(:dummy2) { DummyModel.create!(name: 'Dummy2', active: true, number: 1) }
  let!(:dummy3) { DummyModel.create!(name: 'Dummy3', active: true, number: 2) }

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
        expect { subject }.to raise_error(ArgumentError, 'Params missing: [:name]')
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
        expect(subject).to include(dummy1)
      end
    end

    context "when you don't pass an argument that has default" do
      subject { DummyModels::Query.example_with_default(number: 1) }

      it 'returns Dummy2 because defaults active to false' do
        expect(subject).to include(dummy2)
      end

      context "when you don't pass an argument that has optional == true" do
        it 'returns Dummy2, query still executes because name was optional' do
          expect(subject).to include(dummy2)
        end
      end
    end

    context 'when query has a boolean argument, and the type provided doesnt match' do
      subject { DummyModels::Query.all_args(active: 'not boolean', name: 'Dummy1', number: 1) }

      it 'returns the dummy model that matches criteria' do
        expect { subject }.to raise_error(ArgumentError, ':active must be of type Boolean')
      end
    end

    context 'when query only has 1 argument and is optional' do
      context 'when param is not given' do
        subject { DummyModels::Query.only_optional_argument }

        it 'executes the query properly' do
          expect(subject).to eq(3)
        end
      end

      context 'when param is given' do
        subject { DummyModels::Query.only_optional_argument(number: 1) }

        it 'executes the query properly' do
          expect(subject).to eq(2)
        end
      end
    end

    context 'when optional parameter is explicitly passed as nil' do
      context 'with a Boolean optional parameter' do
        subject { DummyModels::Query.number_if_active(number: 1, active: nil) }

        it 'allows nil and executes the query' do
          expect(subject).to include(dummy1, dummy2)
        end
      end

      context 'with an Integer optional parameter' do
        subject { DummyModels::Query.only_optional_argument(number: nil) }

        it 'allows nil and executes the query' do
          expect(subject).to eq(3)
        end
      end

      context 'with a String optional parameter' do
        subject { DummyModels::Query.example_with_default(number: 1, name: nil) }

        it 'allows nil and executes the query' do
          # Only dummy2 matches because default active: true filters out dummy1 (active: false)
          expect(subject).to include(dummy2)
          expect(subject).not_to include(dummy1)
        end
      end
    end

    context 'when required parameter is passed as nil' do
      context 'with a String required parameter' do
        subject { DummyModels::Query.by_name(name: nil) }

        it 'raises a type error' do
          expect { subject }.to raise_error(ArgumentError, ':name must be of type String')
        end
      end

      context 'with an Integer required parameter' do
        subject { DummyModels::Query.by_number(number: nil) }

        it 'raises a type error' do
          expect { subject }.to raise_error(ArgumentError, ':number must be of type Integer')
        end
      end

      context 'with a Boolean required parameter' do
        subject { DummyModels::Query.all_args(name: 'Dummy1', number: 1, active: nil) }

        it 'raises a type error' do
          expect { subject }.to raise_error(ArgumentError, ':active must be of type Boolean')
        end
      end
    end
  end
end
