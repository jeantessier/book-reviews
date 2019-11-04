require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { "email-#{rand 1_000...10_000}@test.com" }
  let(:password) { "password #{rand 1_000...10_000}" }

  context "" do
    subject { User.new email: email, password: password }

    it "should have an email address and password" do
      expect(subject.email).to eq(email)
    end

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
