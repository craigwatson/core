select :select
from orders
inner join accounts on accounts.id = orders.account_id
inner join customers on customers.id = accounts.customer_id
inner join schedule_rules on schedule_rules.order_id = orders.id
full outer join schedule_pauses on schedule_pauses.id = schedule_rules.schedule_pause_id
where customers.distributor_id = :distributor_id
AND customers.route_id = :route_id
AND orders.active = 't'
AND (	(
		recur is NULL AND schedule_rules.start = ':date'
	)
	OR 
	(
		recur = 'weekly' AND schedule_rules.start <= ':date'
		AND :dow = 't'
	)
	OR 
	(
		recur = 'fortnightly' AND schedule_rules.start <= ':date'
		AND :dow = 't'
		AND (((date(':date') - (schedule_rules.start + CAST((EXTRACT(DOW from date(':date')) - EXTRACT(DOW from schedule_rules.start)) AS integer) + 
			CASE
			WHEN EXTRACT(DOW from schedule_rules.start) > EXTRACT(DOW from date(':date')) THEN 7
			ELSE 0
			END)) / 7) % 2) = 0
	)
	OR
	(
		recur = 'monthly' AND schedule_rules.start <= ':date'
		AND :dow = 't' AND EXTRACT(DAY from date(':date')) < 8
	)
)AND (
	schedule_pauses.start is NULL
	OR
	schedule_pauses.start > (date ':date')
	OR
	schedule_pauses.finish < (date ':date')
)
