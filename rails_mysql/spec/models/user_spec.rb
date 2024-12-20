require 'rails_helper'

RSpec.describe User do
  let(:email) { Faker::Internet.unique.email }
  let(:password) { Faker::Internet.password }

  subject { User.new email:, password: }

  it "should have an email address and password" do
    expect(subject.email).to eq(email)
  end

  context ".save" do
    it "should not save without an email" do
      user = User.new password: password
      expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not save without a password" do
      user = User.new email: email
      expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
