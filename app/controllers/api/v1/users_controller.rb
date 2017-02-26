module Api
  module V1
    class UsersController < ApplicationController
      def show
        render json: User.find(params[:id]), status: 200
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: 201
        else
          render json: { errors: user.errors }, status: 422
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
