require 'ticked'
require 'binding_of_caller'
require 'ripper'

module Ticked
  module Templates
    extend self

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

    def self.parse(template_str)
      file, crnt, strings, exprs = StringIO.new(template_str), "", [], []

      until file.eof?
        str = file.getc
        next crnt << str if str != "$".freeze
        str << file.getc
        next crnt << str if str != "${".freeze
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

      [strings<<crnt, exprs]
    end

    def self.valid?(code)
      Ripper.sexp code
    end
  end
end
