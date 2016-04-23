module Headache
  class DocumentParser
    LINE_SEPARATOR = "\r\n".freeze

    def initialize(string_or_file)
      @ach_string = string_or_file.respond_to?(:read) ? string_or_file.read : string_or_file
    end

    def parse
      fail Headache::InvalidRecordType, invalid_fail_message if invalid_ach?

      Headache::Document.new(
        Record::FileHeader.new(nil).parse(records.shift),
        Record::FileControl.new(nil).parse(records.pop),
        get_batches.map { |b| Headache::Batch.new(self).parse(b) }
      )
    end

    protected

    def records
      @records ||= @ach_string.split(LINE_SEPARATOR).reject { |line| line == Headache::Record::Overflow.new.generate.strip }
    end

    def invalid_fail_message
      "unknown record type(s): #{invalid_lines.map(&:first).inspect}"
    end

    def invalid_ach?
      invalid_lines.any?
    end

    def invalid_lines
      @invalid_lines ||= records.reject { |line| Headache::Record::FileHeader.record_type_codes.values.include?(line.first.to_i) }
    end

    def get_batches
      batches = []
      batch   = []
      records.each do |line|
        if line.starts_with?(Headache::Record::BatchHeader.record_type_codes[:batch_header].to_s)
          batches << batch unless batches.empty? && batch == []
          batch = [line]
        else
          batch << line
        end
      end
      batches << batch
    end
  end
end
