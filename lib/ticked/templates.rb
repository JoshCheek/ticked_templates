require 'ticked'
require 'binding_of_caller'

module Ticked
  module Templates
    extend self

    refine Object do
      def `(template, binding: binding().of_caller(1))
        Templates.`(template, binding: binding) #`
      end
    end

    def `(template, binding: binding().of_caller(1))
      strings, exprs = template.split(/\$\{([^}]*)\}/).partition.with_index { |_,i| i.even? }
      strings << "" unless exprs.size < strings.size
      interpolations = exprs.map &binding.method(:eval)
      Template.new strings: strings, interpolations: interpolations
    end
  end
end
