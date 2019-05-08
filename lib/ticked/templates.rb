require 'ticked'
require 'binding_of_caller'
require 'ripper'

module Ticked
  module Templates
    extend self # for Templates.`

    refine Object do
      def `(template_str, binding: binding().of_caller(1))
        Templates.`(template_str, binding: binding) #`
      end
    end

    def `(template_str, binding: binding().of_caller(1))
      strings, expressions = Templates.parse(template_str)
      interpolations = expressions.map &binding.method(:eval)
      Template.new strings: strings, interpolations: interpolations
    end
  end

  class << Templates
    def parse(template_str)
      stream, strings, exprs = StringIO.new(template_str), [], []
      loop do
        strings << scan_until(stream, "${") { true }
        break if stream.eof?
        exprs << scan_until(stream, "}") { |expr| valid? expr }
      end
      [strings, exprs]
    end

    private

    def scan_until(stream, delimiter)
      str, buffer = "", []
      delimiter.size.times { stream.eof? || buffer << stream.getc }
      loop do
        buffstr = buffer.join("")
        return str if buffstr == delimiter && yield(str)
        return str << buffstr if stream.eof? # uhhm, could probably mask a syntax error, don't think that's tested
        str    << buffer.shift
        buffer << stream.getc
      end
    end

    def valid?(code)
      Ripper.sexp code
    end
  end
end
