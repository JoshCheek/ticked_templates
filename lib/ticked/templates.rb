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
      file = StringIO.new template
      crnt, strings, exprs = "", [], []
      loop do
        if file.eof?
          strings << crnt
          break
        end

        char = file.getc
        if char != "$".freeze
          crnt << char
          next
        end

        char << file.getc
        if char != "${".freeze
          crnt << char
          next
        end

        strings << crnt
        crnt = ""

        loop do
          if file.eof?
            raise "this should prob be a syntax error"
          end
          char = file.getc
          if char != "}"
            crnt << char
          elsif Ripper.sexp(crnt) && !Ripper.sexp(crnt+char)
            exprs << crnt
            crnt = ""
            break
          else
            crnt << char
          end
        end
      end

      interpolations = exprs.map &binding.method(:eval)
      Template.new strings: strings, interpolations: interpolations
    end
  end
end
