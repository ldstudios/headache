require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'

describe Headache::DocumentParser do
  let(:ach_file) {
    File.open('./spec/fixtures/ach').read
    .gsub(Headache::DocumentParser::LINE_SEPARATOR, "\n")
    .gsub("\n", Headache::DocumentParser::LINE_SEPARATOR)
  }

  describe "#parse" do
    let(:doc) { Headache::DocumentParser.new(ach_file) }

    context "when there are invalid records" do
      it "raises an InvalidRecordType error" do
        allow(doc).to receive(:invalid_ach?).and_return(true)
        expect{doc.parse}
        .to raise_error(
          Headache::InvalidRecordType,
          /unknown record type\(s\)/
        )
      end
    end

    context "when there are no invalid records" do
      it "returns a new Headache Document" do
        expect(doc.parse.class).to eq(Headache::Document)
      end
    end
  end
end
