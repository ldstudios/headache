require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'

describe Headache::DocumentParser do
  let(:document) { build :document }
  let(:ach_file) {
    File.open('./spec/fixtures/ach').read
    .gsub(Headache::DocumentParser::LINE_SEPARATOR, "\n")
    .gsub("\n", Headache::DocumentParser::LINE_SEPARATOR)
  }

  let(:ach_hash) {
    JSON.parse(File.open('spec/fixtures/ach.json').read)
  }

  describe "#parse" do
    it 'can be dumped to a hash' do
      doc = described_class.new(ach_file).parse
      expect(doc.to_h.with_indifferent_access).to eq(ach_hash.with_indifferent_access)
    end
  end

  describe "#generate" do
    it 'generates the same document as it parses' do
      doc = described_class.new(ach_file).parse
      expect(doc.generate).to eq(ach_file)
    end

    it 'generates a document where each line is exactly 94 characters' do
      document.generate.split(Headache::DocumentParser::LINE_SEPARATOR).each_with_index do |line, index|
        expect(line.length).to eq(94)
      end
    end
  end
end
