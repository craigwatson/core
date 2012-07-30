require 'spec_helper'

describe Distributor::OrdersController do
  as_distributor

  before do
    Distributor.any_instance.stub_chain(:accounts, :find).and_return(
      @account = mock_model(Account, {
        customer: mock_model(Customer, {
          id: 1, route: @route = mock_model(Route)
        }),
        route: @route,
        id: 675
      })
    )
  end

  describe '#new' do
    it 'should render new' do
      @account.stub_chain(:orders, :build)
      get :new, account_id: @account.id
      response.should render_template('new')
    end
  end

  describe '#edit' do
    it 'should render edit' do
      @order = mock_model(Order, { create_schedule: nil, exclusions: [], substitutions: [] })
      @account.stub_chain(:orders, :find).and_return(@order)
      get :edit, account_id: @account.id, id: 7
      response.should render_template('edit')
    end
  end

  describe '#create' do
    before do
      @order = mock_model(Order, { create_schedule: nil, update_exclusions: true, update_substitutions: true })
      @order.stub(:account_id=)
      @order.stub(:completed=)
      Order.stub(:new).and_return(@order)
    end

    def do_create
      post :create, account_id: @account.id, order: { menu: 'chicken fries' }
    end

    it 'should create an order' do
      Order.should_receive(:new).with('menu' => 'chicken fries', 'account_id' => @account.id, 'completed' => true).and_return(@order)
      @order.stub(:save).and_return(true)
      do_create
    end

    it 'should save the order' do
      Order.should_receive(:new).with('menu' => 'chicken fries', 'account_id' => @account.id, 'completed' => true).and_return(@order)
      @order.stub(:save).and_return(true)
      do_create
    end

    it 'should render new' do
      Order.should_receive(:new).with('menu' => 'chicken fries', 'account_id' => @account.id, 'completed' => true).and_return(@order)
      @order.stub(:save).and_return(false)
      @order.stub(:errors).and_return(['error'])
      do_create
      response.should render_template('new')
    end
  end

  describe '#update' do
    before do
      @order = mock_model(Order, { update_exclusions: true, update_substitutions: true })
      Distributor.any_instance.stub_chain(:orders, :find).and_return(@order)
    end

    def do_update
      put :update, account_id: @account.id, order: { menu: 'roast beef' }, id: 7
    end

    it 'should update order' do
      @order.should_receive(:update_attributes).with('menu' => 'roast beef')
      do_update
    end

    it 'should redirect' do
      @order.stub(:update_attributes).and_return(true)
      do_update
      response.should redirect_to('/distributor/customers/1')
    end

    it 'should render edit' do
      @order.stub(:update_attributes).and_return(false)
      @order.stub(:errors).and_return(['error'])
      do_update
      response.should render_template('edit')
    end
  end
end
