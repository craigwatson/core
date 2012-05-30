class Distributor::PaymentsController < Distributor::ResourceController
  actions :create

  respond_to :html, :xml, :json

  before_filter :load_import_transaction_list, only: [:process_payments, :show]

  def index 
    #@payments = current_distributor.payments.bank_transfer.order('created_at DESC')
    #@import_transaction_lists = current_distributor.import_transaction_lists.ordered.limit(20)
    @import_transaction_list = current_distributor.import_transaction_lists.new
    load_index
  end
  
  def match_payments
    @import_transaction_list = current_distributor.import_transaction_lists.build(params['import_transaction_list'])
    if @import_transaction_list.save
      @import_transaction_list = current_distributor.import_transaction_lists.new
    end
    load_index
    render :index
  end

  def create
    create! do |success, failure|
      success.html { redirect_to distributor_dashboard_url }
      failure.html do
        if params[:payment][:account_id].blank?
          flash[:error] = 'Please, select a customer for this payment.'
        elsif params[:payment][:amount].to_f <= 0
          flash[:error] = 'Please, enter in a positive amount for the payment.'
        elsif params[:payment][:description].blank?
          flash[:error] = 'Please, include a description for this payment.'
        end
        redirect_to distributor_dashboard_url
      end
    end
  end

  def process_payments
    if @import_transaction_list.process_attributes(@import_transaction_list.process_import_transactions_attributes(params[:import_transaction_list]))
      redirect_to distributor_payments_url, notice: "Payments processed successfully"
    else
      flash.now[:alert] = "There was a problem"
      render :match_payments
    end
  end

  def process_upload
    @kiwibank = Bucky::TransactionImports::Kiwibank.new
    @kiwibank.import(params['bank_statement']["statement_file"].path)
    unless @kiwibank.valid?
      return render :index
    end
    @transaction_list = @kiwibank.transactions_for_display(current_distributor)
    render :upload_transactions
  end

  def create_from_csv
    @statement = BankStatement.find(params['statement_id'])
    @statement.process_statement!(params['customers'])

    redirect_to distributor_payments_url
  end

  def destroy
    @import_transaction = current_distributor.import_transactions.find(params[:id])
    if @import_transaction.removed? || @import_transaction.remove!
      render :destroy
    end
  end

  private

  def load_index
    @import_transactions = current_distributor.import_transactions.processed.not_removed.not_duplicate.ordered.limit(50)
    if @import_transactions.present?
      start_date = @import_transactions.first.transaction_date
      end_date = @import_transactions.last.transaction_date
      @import_transaction_lists = current_distributor.import_transaction_lists.draft.select("import_transaction_lists.id").joins(:import_transactions).group("import_transaction_lists.id").having(["max(import_transactions.transaction_date) > ?", end_date]).order("max(import_transactions.transaction_date)")
    else
      @import_transaction_lists = current_distributor.import_transaction_lists.draft.ordered.limit(5)
    end
  end

  def load_import_transaction_list
    @import_transaction_list = current_distributor.import_transaction_lists.find(params[:id])
  end
end
