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

  describe "#first_batch" do
    it "gets the first batch" do
      doc = Headache::DocumentParser.new(ach_file).parse
      expect(doc.first_batch).to eq(doc.batches.first)
    end
  end

  describe "#batch" do
    let(:doc) { Headache::DocumentParser.new(ach_file).parse }

    context "when there are multiple batches" do
      it "raises an exception" do
        expect{doc.batch}.to raise_error(Headache::AmbiguousBatch)
      end
    end

    context "when there's a single batch" do
      it "returns the first batch" do
        allow(doc.batches).to receive(:count).and_return(1)
        expect(doc).to receive(:first_batch)
        doc.batch
      end
    end
  end

  describe "#<<" do
    it "adds the batch" do
      batch = double('batch').as_null_object
      doc = Headache::DocumentParser.new(ach_file).parse
      expect(doc).to receive(:add_batch).with(batch)
      doc << batch
    end

    it "returns self" do
      batch = double('batch').as_null_object
      doc = Headache::DocumentParser.new(ach_file).parse
      expect(doc << batch).to eq(doc)
    end
  end

  describe "#to_h" do
    let(:doc) { Headache::DocumentParser.new(ach_file) }
    let(:ach_hash) { JSON.parse(File.open('spec/fixtures/ach.json').read) }

    it 'can be dumped to a hash' do
      expect(doc.parse.to_h.with_indifferent_access).to eq(ach_hash.with_indifferent_access)
    end
  end
end
