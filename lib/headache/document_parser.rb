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
      @records ||= @ach_string.split(LINE_SEPARATOR).reject { |record| record == Headache::Record::Overflow.new.generate.strip }
    end

    def invalid_fail_message
      "unknown record type(s): #{invalid_records.map(&:first).inspect}"
    end

    def invalid_ach?
      invalid_records.any?
    end

    def invalid_records
      @invalid_records ||= records.reject { |record| Headache::Record::FileHeader.record_type_codes.values.include?(record.first.to_i) }
    end

    def get_batches
      batches = []
      batch   = []
      records.each do |record|
        if record.starts_with?(Headache::Record::BatchHeader.record_type_codes[:batch_header].to_s)
          batches << batch unless batches.empty? && batch == []
          batch = [record]
        else
          batch << record
        end
      end
      batches << batch
    end
  end
end
