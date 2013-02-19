class Customer::CustomersController < Customer::ResourceController
  actions :update

  respond_to :html, :xml, :json

  def update
    update! do |success, failure|
      success.html { redirect_to customer_root_url, notice: 'Your information has successfully been updated.' }
      failure.html { redirect_to customer_root_url, flash:{ error: current_customer.errors.full_messages.join(', ')} }
    end
  end

  def update_password
    params[:customer][:password].strip! rescue nil #Customers copy and paste password from email, sometimes grabbing a bit of whitespace
    params[:customer][:password_confirmation].strip! rescue nil
    respond_to do |format|
      if current_customer.update_attributes(params[:customer])
        sign_in current_customer, bypass: true

        format.html { redirect_to customer_root_url, notice: 'Password successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to customer_root_url, flash: {error: "There was a problem changing your password. #{current_customer.errors.full_messages.join(', ')}"} }
        format.json { render json: current_customer.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def resource
    current_customer
  end

  def begin_of_association_chain
    nil
  end
end
