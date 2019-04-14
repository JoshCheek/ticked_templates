require 'ticked'

module SpecHelpers
  def eq!(expected, actual)
    expect(expected).to eq actual
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end

RSpec.describe Ticked::Templates do
  def `(str)
    :unrefined
  end

  describe 'the tick helper' do
    it 'provides a refinement to define the tick on Object' do
      eq! :unrefined, ``
      eq! '121', lambda { using Ticked::Templates; `1${1+1}1` }.call
      eq! :unrefined, ``
    end

    it 'provides an unrefined version available on Ticked::Templates' do
      eq! '121', Ticked::Templates.`1${1+1}1`
    end

    specify 'the tick is available via mixin' do
      eq! '121', Class.new { include Ticked::Templates }.new.`1${1+1}1`
      eq! '121', Object.new.extend(Ticked::Templates).`1${1+1}1`
    end

    specify 'it returns a Ticked::Template' do
      eq! Ticked::Template, Ticked::Templates.``
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
    eq! %w[abc def ghi], `abc${1}def${2}ghi`
  end

  it 'knows the interpolations' do
    eq! [1, 2], `abc${1}def${2}ghi`
  end

  it 'is coercable into a string' do
    eq! "ab", "a"+`b`
  end

  it 'is coercable into a hash' do
    seen = []
    ae! [%w[a b], [1]],
        lambda { |strings:, interpolations:|
          seen << strings << interpolations
        }.(`a${1}b`)
  end
end
