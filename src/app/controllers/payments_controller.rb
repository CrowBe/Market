class PaymentsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:stripe]

    def new
        base_url = ENV.fetch('APP_BASE_URL', 'http://localhost:3000')
        stripe_session = Stripe::Checkout::Session.create(
            customer_email: current_user.email,
            payment_method_types: ['card'],
            client_reference_id: current_user.id,
            line_items: [{
                name: current_user.email,
                description: "One off Payment to HobbyBuddies",
                amount: 1000,
                currency: 'aud',
                quantity: 1,
            }],
            success_url: "#{base_url}/payments/success",
            cancel_url: "#{base_url}/cancel"
        )
        @stripe_session_id = stripe_session.id
    end

    def stripe
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']

        begin
            event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
        rescue JSON::ParserError, Stripe::SignatureVerificationError
            head :bad_request and return
        end

        if event['type'] == 'checkout.session.completed'
            session = event['data']['object']
            user = User.find_by(id: session['client_reference_id'])
            if user
                user.update(paid: true)
            end
        end

        render json: { received: true }
    end

    def success
        redirect_to new_profile_path
    end

end

