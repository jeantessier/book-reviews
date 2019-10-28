require "rails_helper"

RSpec.describe Book do

  subject { Book.new(name: expected_name) }
  let(:expected_name) { "name #{rand 1_000...10_000}" }

  it "should have a name" do
    expect(subject.name).to eq(expected_name)
  end

end
