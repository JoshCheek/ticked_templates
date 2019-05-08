require 'spec_helper'

RSpec.describe Ticked::CASE_CLOSED do
  it 'explodes if used in a case statement' do
    begin
      case "hihii"
      when described_class
      end
    rescue Ticked::CASE_CLOSED::CaseStatementError => e
      error = e
    end
    expect(error.value).to eq 'hihii'
    expect(error.message).to match /unexpected/i
  end
end
