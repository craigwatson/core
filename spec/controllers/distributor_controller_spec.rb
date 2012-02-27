require 'spec_helper'

describe DistributorsController do
  render_views

  before(:each) do
    @distributor = Fabricate(:distributor, :completed_wizard => true, name: 'r2d2')
    @customer = Fabricate(:customer, :distributor => @distributor)
    sign_in @distributor
  end

  describe '#update' do
    context 'with valid params' do
      before(:each) do
        put :update, {id: @distributor.id, distributor: {name: 'Yoda'}}
      end
      specify { flash[:notice].should eq("Distributor was successfully updated.") }
      specify { assigns(:distributor).name.should eq('Yoda') }
      specify { response.should redirect_to(contact_info_distributor_settings_path(@distributor)) }
    end
    context 'with invalid params' do
      before(:each) do
        put :update, {id: @distributor.id, distributor: {name: ''}}
      end
      specify { assigns(:distributor).errors.size.should eq(1) }
      specify { assigns(:distributor).name.should eq('') }
      specify { response.should render_template('distributor/settings/contact_info') }
    end
  end
end
