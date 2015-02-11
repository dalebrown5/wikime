class ChargesController < ApplicationController

  def upgradeable
    current_user.role = "standard"
  end

  def create
    # if upgradeable
      # Creates a Stripe Customer object, for associating
      # with the charge
      customer = Stripe::Customer.create(
        email: current_user.email,
        card: params[:stripeToken]
      )
     
      # Where the real magic happens
      charge = Stripe::Charge.create(
        customer: customer.id, # Note -- this is NOT the user_id in your app
        amount: 1500,
        description: "Premium Membership - #{current_user.email}",
        currency: 'usd'
      )
     
      current_user.role = "premium"
      current_user.save
      flash[:success] = "#{current_user.email}! Premium member status set."
      redirect_to user_path(current_user) # or wherever
     
      # Stripe will send back CardErrors, with friendly messages
      # when something goes wrong.
      # This `rescue block` catches and displays those errors.
      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_charge_path
      
    # else
    #   flash[:error] = "Already a premium account"
    #   redirect to wikis_path
    # end
  end

  def new
    @stripe_btn_data = {
      key: "#{ Rails.configuration.stripe[:publishable_key] }",
      description: "Premium Membership - #{current_user.name}",
      amount: 1500
    }
  end 

end
