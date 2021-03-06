module Distributor::DashboardHelper
  # NOTE: Events will be cleaned up eventually likely moving this case statement into a more OO design.
  def notification_message_for(notification)
    case notification.event_type
    when Event::EVENT_TYPES[:customer_new]
      customer = notification.customer
      "New customer #{link_to_customer customer}".html_safe

    when Event::EVENT_TYPES[:customer_webstore_new]
      customer = notification.customer
      "New webstore customer #{link_to_customer customer}".html_safe

    when Event::EVENT_TYPES[:customer_call_reminder]
      customer = notification.customer
      "Follow up call #{link_to_customer customer}".html_safe

    when Event::EVENT_TYPES[:delivery_scheduler_issue]
      "Delivery Scheduler could not schedule a #{link_to_delivery notification.delivery_id}".html_safe

    when Event::EVENT_TYPES[:delivery_pending]
      "A #{link_to_delivery notification.delivery_id} is still marked as pending".html_safe

    when Event::EVENT_TYPES[:credit_limit_reached]
      customer = notification.customer
      "Credit Limit reached for #{link_to_customer customer}, deliveries will be halted".html_safe

    when Event::EVENT_TYPES[:payment_overdue]
      customer = notification.customer
      "Payment overdue for #{link_to_customer customer}".html_safe

    when Event::EVENT_TYPES[:transaction_success]
      transaction = notification.transaction
      "#{link_to_transaction transaction.id} was successfully made (#{transaction.amount})".html_safe

    when Event::EVENT_TYPES[:transaction_failure]
      transaction = notification.transaction
      "#{link_to_transaction transaction.id} declined, will try again next week (#{transaction.amount})".html_safe
    end
  end

  def link_to_customer(customer)
    link_to "#{customer.name} (ID:#{customer.id})", distributor_customer_path(customer.id)
  end

  def link_to_delivery(delivery_id)
    link_to "delivery", distributor_delivery_path(delivery_id)
  end

  def link_to_transaction(transaction_id)
    link_to "Transaction ##{transaction_id}", distributor_transaction_path(transaction_id)
  end

  def date_for(notification)
    notification.created_at.to_s(:date_month)
  end

  def time_since(timestamp)
    return "Never" if timestamp.blank?

    days = days_between(timestamp.to_date, Date.today)

    if days > 180
      timestamp.to_s(:day_month_and_year)
    elsif days > 4
      timestamp.to_s(:date_short_month)
    else
      time_ago_in_words(timestamp) + " ago"
    end
  end

private

  def days_between(date_a, date_b)
    (date_a - date_b).to_i.abs
  end
end
