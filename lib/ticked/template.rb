module Ticked
  class Template
    STRING_TYPE = :string
    INTERP_TYPE = :interpolation

    attr_reader :strings, :interpolations

    def initialize(strings:, interpolations:)
      self.strings        = strings.map(&:freeze).freeze
      self.interpolations = interpolations.freeze
    end

    def inspect
      pieces = map do |type, value|
        case type
        when STRING_TYPE then value
        when INTERP_TYPE then "${#{value.inspect}}"
        else raise "Wat: #{type.inspect}"
        end
      end
      "`#{pieces.join('')}`"
    end

    def to_s
      map { |_, value| value }.join("")
    end
    alias to_str to_s

    def to_h
      { strings: strings, interpolations: interpolations }
    end

    def to_hash
      { strings: strings, interpolations: interpolations }
    end

    include Enumerable
    def each
      return to_enum unless block_given?
      strs = strings.each
      vals = interpolations.each
      loop do
        yield STRING_TYPE, strs.next
        yield INTERP_TYPE, vals.next
      end
    end

    private

    attr_writer :strings, :interpolations
  end
end
