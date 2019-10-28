require "rails_helper"

RSpec.describe Book do
  it "should have a name" do
    expected_name = "name #{rand 1_000...10_000}"

    book = Book.new
    book.name = expected_name

    expect(book.name).to eq expected_name
  end
end
