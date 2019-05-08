module Ticked
  module CASE_CLOSED
    class CaseStatementError < StandardError
      attr_reader :value
      def initialize(value)
        @value = value
        super "Case statement received an unexpected value: #{value.inspect}"
      end
    end

    extend self

    def ===(value)
      raise CaseStatementError, value, caller()
    end
  end
end
