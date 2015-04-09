require 'spec_helper'

describe HtmlMapper::Field do

  let(:doc){ Nokogiri::HTML.parse(fixture_file('field.html'))}

  module FieldTest
    class Event
      def process_over(text, ele)
        "10#{text}"
      end
    end
  end

  let(:event) { FieldTest::Event.new }

  describe 'initialization' do
    it 'new field with selector' do
      field = described_class.new(:name, '.name, .title')

      expect(field.name).to eq :name
      expect(field.selector).to eq(['.name', '.title'])
    end
  end

  describe 'find' do
    it 'field with default options' do
      field = described_class.new(:over, '.over')

      expect(field.find(doc, event)).to eq('0.1')
    end

    it 'field with type option' do
      field = described_class.new(:over, '.over', as: Float)

      expect(field.find(doc, event)).to eq(0.1)
    end

    it 'field with eval option as symbol' do
      field = described_class.new(:over, '.over', as: Float, eval: :process_over)

      expect(field.find(doc, event)).to eq(100.1)
    end

    it 'field with eval option as proc' do
      field = described_class.new(:over, '.over', as: Float, eval: ->(text, ele) { "20#{text}"})

      expect(field.find(doc, event)).to eq(200.1)
    end

    it 'field with html element attribute' do
      field = described_class.new(:web, 'a', attribute: 'href')

      expect(field.find(doc, event)).to eq('http://foo.com')
    end

  end

end
