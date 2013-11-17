require 'spec_helper'

describe PasswordsController do
  let(:user) { Fabricate(:user) }

  describe '.edit' do
    context "you can view it even if login is required" do
      before do
        SiteSetting.stubs(:login_required).returns(true)
        get :edit, token: 'asdfasdf'
      end

      it "returns success" do
        response.should be_success
      end
    end

    context 'invalid token' do
      before do
        EmailToken.expects(:confirm).with('asdfasdf').returns(nil)
        get :edit, token: 'asdfasdf'
      end

      it 'return success' do
        response.should be_success
      end

      it 'sets a flash error' do
        flash[:error].should be_present
      end

      it "doesn't log in the user" do
        session[:current_user_id].should be_blank
      end
    end
  end

  describe '.update' do
    context 'valid token' do
      before do
        EmailToken.expects(:confirm).with('asdfasdf').returns(user)
        put :update, token: 'asdfasdf', password: 'newpassword'
      end

      it 'returns success' do
        response.should be_success
      end

      it "doesn't set an error" do
        flash[:error].should be_blank
      end
    end

    context 'submit change' do
      before do
        EmailToken.expects(:confirm).with('asdfasdf').returns(user)
      end

      it "logs in the user" do
        put :update, token: 'asdfasdf', password: 'newpassword'
        session[:current_user_id].should be_present
      end

      it "doesn't log in the user when not approved" do
        SiteSetting.expects(:must_approve_users?).returns(true)
        put :update, token: 'asdfasdf', password: 'newpassword'
        session[:current_user_id].should be_blank
      end
    end
  end
end
