module Ticked
  class Template
    STRING_TYPE = :string
    INTERP_TYPE = :interpolation
    DELIMITER   = '`'.freeze

    attr_reader :strings, :interpolations

    def initialize(strings:, interpolations:)
      self.strings        = strings.map(&:freeze).freeze
      self.interpolations = interpolations.freeze
    end

    def inspect
      ( reduce DELIMITER.dup do |str, (type, value)|
          str << case type
          when STRING_TYPE then value
          when INTERP_TYPE then "${#{value.inspect}}"
          else raise "Wut: #{type.inspect}"
          end
        end
      ) << DELIMITER
    end

    def ==(strings:, interpolations:)
      strings() == strings && interpolations() == interpolations
    end

    alias_method :to_s, def to_str
      map { |_, value| value }.join("")
    end

    alias_method :to_h, def to_hash
      { strings: strings, interpolations: interpolations }
    end

    include Enumerable
    def each
      return to_enum unless block_given?
      strs, interps = strings.each, interpolations.each
      loop do
        yield STRING_TYPE, strs.next
        yield INTERP_TYPE, interps.next
      end
    end

    private

    attr_writer :strings, :interpolations
  end
end
