class ApplicationController < ActionController::Base
    include Pagy::Backend
    before_action :sign_up_path
    private

    # Altering Devise's method to ensure a flash notice tells the user why they were redirected
    def authenticate_user!
        unless current_user
          flash[:notice] = "Sorry! You need to sign in or sign up before using that part of our site."
          redirect_to new_user_session_path
        end
    end

    # A custom method to ensure the user follows the correct sign up path
    def sign_up_path
        path = "#{params[:controller]}/#{params[:action]}"
        if user_signed_in? and path != "devise/sessions/destroy"
            if !current_user.paid? 
                p params
                redirect_to new_payment_path unless path == "payments/new"
            elsif current_user.profile.blank? and path != "profiles/create"
                redirect_to new_profile_path unless path == "profiles/new"
            elsif !current_user.profile.blank?
                redirect_to profile_path(current_user.profile) if path == "profiles/new"
            end
        end
    end
end
