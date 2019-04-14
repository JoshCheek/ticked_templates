require 'ticked'

module SpecHelpers
  def eq!(expected, actual)
    actual = actual.to_str  if expected.is_a?(String) && actual.respond_to?(:to_str)
    actual = actual.to_hash if expected.is_a?(Hash)   && actual.respond_to?(:to_hash)
    expect(actual).to eq expected
  rescue RSpec::Expectations::ExpectationNotMetError
    $!.set_backtrace caller.drop(1)
    raise
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
  config.color     = true
  config.formatter = 'documentation'
  config.fail_fast = true
end

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

  it 'always has a leading and trailing string' do
    eq! [''], ``.strings
    eq! ['', ''], `${1}`.strings
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
end
