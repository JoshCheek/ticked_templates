require 'ticked'
require 'binding_of_caller'
require 'ripper'

module Ticked
  module Templates
    extend self

    refine Object do
      def `(template, binding: binding().of_caller(1))
        Templates.`(template, binding: binding) #`
      end
    end

    def `(template, binding: binding().of_caller(1))
      strings, expressions = parse(template)
      interpolations = expressions.map &binding.method(:eval)
      Template.new strings: strings, interpolations: interpolations
    end

    private

    def parse(template)
      file = StringIO.new template
      crnt, strings, exprs = "", [], []
      until file.eof?
        char = file.getc
        next crnt << char if char != "$".freeze
        char << file.getc
        next crnt << char if char != "${".freeze
        strings << crnt
        crnt = ""

        loop do
          raise "this should prob be a syntax error" if file.eof?
          char = file.getc
          next crnt << char if char != "}".freeze || !valid?(crnt) || valid?(crnt+char)
          exprs << crnt
          crnt = ""
          break
        end
      end
      strings << crnt
      [strings, exprs]
    end

    def valid?(code)
      Ripper.sexp(code)
    end
  end
end
