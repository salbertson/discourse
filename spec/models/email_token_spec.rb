require 'spec_helper'

describe EmailToken do

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :email }
  it { should belong_to :user }


  context '#create' do
    let(:user) { Fabricate(:user, active: false) }
    let!(:original_token) { user.email_tokens.first }
    let!(:email_token) { user.email_tokens.create(email: 'bubblegum@adevnturetime.ooo') }

    it 'should create the email token' do
      email_token.should be_present
    end

    it 'is valid' do
      email_token.should be_valid
    end

    it 'has a token' do
      email_token.token.should be_present
    end

    it 'is not confirmed' do
      email_token.should_not be_confirmed
    end

    it 'is not expired' do
      email_token.should_not be_expired
    end

    it 'marks the older token as expired' do
      original_token.reload
      original_token.should be_expired
    end
  end

  context '#confirm' do
    let(:user) { Fabricate(:user, active: false) }
    let(:email_token) { user.email_tokens.first }

    it 'returns nil with a nil token' do
      EmailToken.confirm(nil).should be_blank
    end

    it 'returns nil with a made up token' do
      EmailToken.confirm(EmailToken.generate_token).should be_blank
    end

    it 'returns nil unless the token is the right length' do
      EmailToken.confirm('a').should be_blank
    end

    it 'returns nil when a token is expired' do
      email_token.update_column(:expired, true)
      EmailToken.confirm(email_token.token).should be_blank
    end

    it 'returns nil when a token is older than a specific time' do
      EmailToken.expects(:valid_after).returns(1.week.ago)
      email_token.update_column(:created_at, 2.weeks.ago)
      EmailToken.confirm(email_token.token).should be_blank
    end
  end
end
