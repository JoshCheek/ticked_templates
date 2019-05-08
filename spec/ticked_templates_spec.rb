require 'spec_helper'

RSpec.describe Ticked::Templates do
  def `(str)
    :unrefined
  end

  describe 'the tick helper' do
    it 'provides a refinement to define the tick on Object' do
      eq! :unrefined, ``
      eq! '121', Class.new.class_eval { using Ticked::Templates; `1${1+1}1` }
      eq! :unrefined, ``
    end

    it 'provides an unrefined version available on Ticked::Templates' do
      eq! '121', Ticked::Templates.`('1${1+1}1') #`
    end

    specify 'the tick is available via mixin' do
      eq! '121', Class.new { include Ticked::Templates }.new.`('1${1+1}1') #`
      eq! '121', Object.new.extend(Ticked::Templates).`('1${1+1}1') #`
    end

    specify 'it returns a Ticked::Template' do
      eq! Ticked::Template, Ticked::Templates.`("").class #`
    end
  end
end

RSpec.describe Ticked::Template do
  using Ticked::Templates

  it 'evaluates the interpolations in the context of the caller' do
    a, b = 10, 2
    eq! '(12)', `(${a+b})`
  end

  it 'knows the strings between the interpolations' do
    eq! %w[abc def ghi], `abc${1}def${2}ghi`.strings
  end

  it 'knows the interpolations' do
    eq! [1, 2], `abc${1}def${2}ghi`.interpolations
  end

  it 'allows the last string to be chomped, returning a new template' do
    t1 = `a${1}b\n\n`
    t2 = t1.chomp
    t3 = t2.chomp
    t4 = t3.chomp
    eq! `a${1}b\n\n`, t1
    eq! `a${1}b\n`,   t2
    eq! `a${1}b`,     t3
    eq! `a${1}b`,     t4
  end

  it 'can be flattened, which will merge nested templates up into it' do
    a = ``
    b = `b`
    c = `c${b}${a}${1}c`
    d = `d${c}d`
    eq! `dcb${1}cd`,        d.flatten()
    eq! d,                  d.flatten(0)
    eq! `dc${b}${a}${1}cd`, d.flatten(1)
    eq! d.flatten,          d.flatten(2)
  end

  it 'is coercable into a string' do
    eq! "ab", "a"+`b`
    eq! "ab", "a#{`b`}"
  end

  it 'is coercable into a hash' do
    eq! [%w[a b], [1]],
        lambda { |strings:, interpolations:|
          [strings, interpolations]
        }.(`a${1}b`)
    eq!(
      { strings: ['b', ''], interpolations: [1] },
      `b${1}`.to_h, # can't remember anything that will explicitly call this
    )
  end

  it 'is enumerable, yielding the components and their types in order' do
    eq!(
      [[:string, 'a'], [:interpolation, 2], [:string, 'b']],
      `a${1+1}b`.to_a
    )
  end

  it 'returns itself from #each' do
    eq! `a`, `a`.each { }
  end

  it 'always has a leading, trailing, and delimiting string' do
    eq! [''], ``.strings
    eq! ['', ''], `${1}`.strings
    eq! ['', '', ''], `${1}${2}`.strings
    eq! ['a', 'b', 'c'], `a${1}b${2}c`.strings
  end

  it 'is multiline' do
    eq!(
      { strings: ["abc\ndef ", " ghi\njkl\n"], interpolations: [3] },
      <<~`STR`
        abc
        def ${ 1 +
        2 } ghi
        jkl
      STR
    )
  end

  it 'can parse complex stuff in the interpolations' do
    eq! [{a: 1, b: 2}, `a${1+1}b`, "}", "}", ""],
        <<~`STR`.interpolations
          ${{a: 1, b: 2}}
          ${`a${1+1}b`}
          ${"}"}
          ${?}}
          ${%}}}
        STR
  end
end
