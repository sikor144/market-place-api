require 'spec_helper'

describe Api::V1::ProductsController do

  describe "GET #show" do
    let(:product) { create(:product) }

    it "returns the information about a reporter on a hash" do
      response = get :show, format: :json, params: { id: product.id }
      response = JSON.parse(response.body, symbolize_names: true)
      expect(response[:title]).to eq product.title
    end

    it "has the user as a embeded object" do
      response = get :show, format: :json, params: { id: product.id }
      response = JSON.parse(response.body, symbolize_names: true)
      expect(response[:user][:email]).to eq product.user.email
    end

    it "responds with status 200" do
      get :show, format: :json, params: { id: product.id }
      is_expected.to respond_with 200
    end
  end

  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :product }
    end

    context "when is not receiving any product_ids parameter" do
      before(:each) do
        @response = get :index, format: :json
      end

      it "returns 4 records from the database" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response.count).to eq 4
      end

      it "returns the user object into each product" do
        response = JSON.parse(@response.body, symbolize_names: true)
        response.each do |product_response|
          expect(product_response[:user]).to be_present
        end
      end

      it { should respond_with 200 }
    end
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        @product_attributes = FactoryGirl.attributes_for :product
        api_authorization_header user.auth_token
        @response = post :create, format: :json, params: { user_id: user.id, product: @product_attributes }
      end

      it "renders the json representation for the product record just created" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response[:title]).to eq @product_attributes[:title]
      end

      it { should respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_product_attributes = { title: "Smart TV", price: "Twelve dollars" }
        api_authorization_header user.auth_token
        @response = post :create, format: :json, params: { user_id: user.id, product: @invalid_product_attributes }
      end

      it "renders an errors json" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context "when is successfully updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id, product: { title: "An expensive TV" } }
      end

      it "renders the json representation for the updated user" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response[:title]).to eq "An expensive TV"
      end

      it { should respond_with 200 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id, product: { price: "two hundred" } }
      end

      it "renders an errors json" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response).to have_key(:errors)
      end

      it "renders the json errors on whye the user could not be created" do
        response = JSON.parse(@response.body, symbolize_names: true)
        expect(response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @product.id }
    end

    it { should respond_with 204 }
  end

end
