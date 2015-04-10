require 'spec_helper'

describe HtmlMapper::SupportedTypes do

  let(:typecaster) { described_class }

  describe 'typecast' do
    it 'integer' do
      value = typecaster.types[Integer].apply('100')

      expect(value).to eq 100
    end

    it 'integer with nil value' do
      value = typecaster.types[Integer].apply('text')

      expect(value).to eq nil
    end

    it 'integer with text number' do
      value = typecaster.types[Integer].apply(' 100text')

      expect(value).to eq 100
    end

    it 'integer with random text' do
      value = typecaster.types[Integer].apply('rt')

      expect(value).to eq nil
    end

    it 'boolean "true"' do
      value = typecaster.types[HtmlMapper::Boolean].apply('true')

      expect(value).to be true
    end

    it 'boolean text "t"' do
      value = typecaster.types[HtmlMapper::Boolean].apply('t')

      expect(value).to be true
    end

    it 'boolean text "1"' do
      value = typecaster.types[HtmlMapper::Boolean].apply('1')

      expect(value).to be true
    end

    it 'boolean text "random"' do
      value = typecaster.types[HtmlMapper::Boolean].apply('random')

      expect(value).to be false
    end

    it 'float with greater then zero' do
      value = typecaster.types[Float].apply('11.20')

      expect(value).to be 11.20
    end

    it 'float with  zero value' do
      value = typecaster.types[Float].apply('0.0')

      expect(value).to be 0.0
    end

    it 'float with text value' do
      value = typecaster.types[Float].apply('nf')

      expect(value).to be_nil
    end
  end
end
