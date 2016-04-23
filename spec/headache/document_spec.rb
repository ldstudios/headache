require 'spec_helper'

describe Headache::Document do
  let(:document) { build :document }
  let(:ach_file) {
    File.open('./spec/fixtures/ach').read
    .gsub(Headache::DocumentParser::LINE_SEPARATOR, "\n")
    .gsub("\n", Headache::DocumentParser::LINE_SEPARATOR)
  }

  describe "#generate" do
    it 'generates the same document as it parses' do
      doc = Headache::DocumentParser.new(ach_file).parse
      expect(doc.generate).to eq(ach_file)
    end

    it 'generates a document where each line is exactly 94 characters' do
      document.generate.split(Headache::DocumentParser::LINE_SEPARATOR).each_with_index do |line, index|
        expect(line.length).to eq(94)
      end
    end
  end
end
