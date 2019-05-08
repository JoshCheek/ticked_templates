require 'ticked'
require 'binding_of_caller'
require 'ripper'

module Ticked
  module Templates
    extend self

    def `(template_str, binding: binding().of_caller(1))
      strings, expressions = Templates.parse(template_str)
      interpolations = expressions.map &binding.method(:eval)
      Template.new strings: strings, interpolations: interpolations
    end

    refine Object do
      def `(template_str, binding: binding().of_caller(1))
        Templates.`(template_str, binding: binding) #` comment is here to fix editor highlighting
      end
    end

    OPEN  = ["$", "{"].map(&:freeze).freeze
    CLOSE = ["}"].map(&:freeze).freeze
    private_constant :OPEN
    private_constant :CLOSE

    def self.parse(template_str)
      stream, strings, exprs = StringIO.new(template_str), [], []
      loop do
        strings << scan_until(stream, OPEN) { true }
        break if stream.eof?
        exprs << scan_until(stream, CLOSE) { |expr| valid? expr }
      end
      [strings, exprs]
    end

    private_class_method def self.scan_until(stream, delim)
      scanned, buffer = "", []
      delim.size.times { stream.eof? || buffer << stream.getc }
      loop do
        return scanned if match?(delim, buffer) && yield(scanned)
        return scanned << buffer.join("") if stream.eof? # uhhm, could probably mask a syntax error, don't think that's tested
        scanned << buffer.shift
        buffer  << stream.getc
      end
    end

    private_class_method def self.match?(buffer, delimiter)
      buffer.each_index.all? do |index|
        buffer[index] == delimiter[index]
      end
    end

    private_class_method def self.valid?(code)
      Ripper.sexp code
    end
  end
end
