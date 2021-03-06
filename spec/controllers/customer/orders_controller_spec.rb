require 'spec_helper'

describe Customer::OrdersController do
  render_views
  sign_in_as_customer

  describe "PUT 'update'" do
    before do
      @order = Fabricate(:order, quantity: 1, account: @customer.account)
      @id = @order.id
      @order_params = { quantity: 3 }
    end

    describe 'with valid params' do
      before { put :update, { id: @id, order: @order_params } }

      specify { expect(assigns(:order)).to be_a(Order) }
      specify { expect(assigns(:order)).to be_persisted }
      specify { expect(assigns(:order).quantity).to eq 3 }
    end

    describe 'with invalid params' do
      before do
        @order_params[:quantity] = 'all of the times!'
        put :update, { id: @id, order: @order_params }
      end

      specify { expect(Order.last.quantity).to eq 1 }
      specify { expect(response).to render_template('edit') }
    end

    context "with customer_can_edit_orders = false" do
      before do
        distributor = @customer.distributor
        distributor.update_attributes(customer_can_edit_orders: false)
      end

      it "does not update the order" do
        @order_params[:quantity] = 2
        put :update, { id: @id, order: @order_params }

        expect(@order.reload.quantity).not_to eq 2
      end
    end
  end

  context "pausing" do
    let(:order) { Fabricate(:order) }
    describe "#pause" do
      it "should pause the order" do
        date = order.next_occurrences(2, Date.current).last
        put :pause, { id: order.id, account_id: order.account_id, date: date }
        expect(assigns(:order).pause_date).to eq(date)
      end
    end

    describe "#remove_pause" do
      it "should remove the pause from an order" do
        order.pause!(Date.tomorrow)
        put :remove_pause, { id: order.id, account_id: order.account_id }
        expect(order.reload.pause_date).to be_nil
      end
    end

    describe "#resume" do
      it "should resume the order" do
        dates = order.next_occurrences(5, Date.current)
        order.pause!(dates[2])
        put :resume, { id: order.id, account_id: order.account_id, date: dates[4] }
        order.reload
        expect(order.pause_date).to eq(dates[2])
        expect(order.resume_date).to eq(dates[4])
      end
    end

    describe "#remove_resume" do
      it "should resume the order" do
        dates = order.next_occurrences(5, Date.current)
        order.pause!(dates[4], dates[5])
        post :remove_resume, { id: order.id, account_id: order.account_id }
      end
    end
  end

  describe "#deactivate" do
    let(:order) { Fabricate(:order, account: @customer.account) }

    it "should deactivate the order" do
      d = @customer.distributor
      d.customer_can_remove_orders = true
      d.save

      put :deactivate, { id: order.id }
      expect(order.reload.active).to be false
    end

    it "should only allow deactivating your own orders" do
      other_customer = Fabricate(:customer)
      other_order = Fabricate(:order, account: other_customer.account)
      expect { put :deactivate, { id: other_order.id } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should only deactivate if enabled via admin's distributor settings" do
      distributor = @customer.distributor
      distributor.customer_can_remove_orders = false
      distributor.save!
      put :deactivate, { id: order.id }
      expect(order.reload.active).to be true
    end
  end
end
