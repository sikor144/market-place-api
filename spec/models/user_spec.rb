require 'spec_helper'

describe User do
  subject { build(:user) }

  describe 'validations' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:password) }
    it { is_expected.to respond_to(:password_confirmation) }

    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to allow_value('example@domain.com').for(:email) }
  end
end
