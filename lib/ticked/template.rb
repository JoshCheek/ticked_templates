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

    def chomp
      last = strings.last.chomp
      return self if last == strings.last
      new_strings = strings.dup
      new_strings[-1] = last
      self.class.new strings: new_strings, interpolations: interpolations
    end

    def flatten(depth=Float::INFINITY)
      strings, interpolations, prev = [], [], nil
      recursive_each depth do |type, val|
        case type
        when STRING_TYPE
          if prev == STRING_TYPE
            strings[-1] += val
          else
            strings << val
          end
        when INTERP_TYPE
          interpolations << val
        end
        prev = type
      end
      self.class.new(strings: strings, interpolations: interpolations)
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

    def each(&block)
      recursive_each(1, &block)
    end

    private

    attr_writer :strings, :interpolations

    protected

    def recursive_each(depth, &block)
      return to_enum(:each, depth: depth) unless block
      strs, interps = strings.each, interpolations.each
      loop do
        block[STRING_TYPE, strs.next]
        interp = interps.next
        if 0 < depth && Template === interp
          interp.recursive_each depth-1, &block
        else
          block[INTERP_TYPE, interp]
        end
      end
      self
    end
  end
end
