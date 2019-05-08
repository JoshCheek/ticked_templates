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
