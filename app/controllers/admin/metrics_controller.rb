class Admin::MetricsController < Admin::BaseController
  layout false

  caches_action :transactional_customers, expires_in: 1.week
  def transactional_customers
    beginning = 3.years.ago.to_date
    yesterday = Time.now.utc.to_date - 1.day
    data = []
    previous_cumulative_count = 0
    period = ((yesterday - beginning) / 7).floor

    period.times do |week|
      date = yesterday - (week + 1).weeks

      cumulative_count = Bucky::Sql.transactional_customer_count(nil, date)
      current_count = cumulative_count - previous_cumulative_count
      previous_cumulative_count = cumulative_count

      current_date = (week.even? ? date.iso8601 : "")

      data_struct = OpenStruct.new(date: current_date, count: current_count)

      data << data_struct
    end

    data.reverse!

    render locals: { data: data }
  end

  caches_action :sales, expires_in: 1.day
  def sales
    require 'money'
    require 'eu_central_bank'
    require 'monetize'

    eu_bank = EuCentralBank.new
    eu_bank.update_rates
    Money.default_bank = eu_bank

    data = Distributor.paying.map do |distributor|
      amount = distributor.invoices.last.try(:amount)
      next unless amount

      currency = distributor.pricing.currency

      money = Monetize.parse("#{currency} #{amount}")
      amount = money.exchange_to(:NZD)

      label = "#{distributor.name} (#{distributor.pricing.name})"

      OpenStruct.new(label: label, amount: amount)
    end.compact.sort_by(&:amount).reverse

    render locals: { data: data }
  end
end
