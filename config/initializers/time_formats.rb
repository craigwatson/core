Time::DATE_FORMATS[:month_and_year] = "%B %Y"
Time::DATE_FORMATS[:timestamp] = "%Y-%m-%d %H:%M:%S"
Time::DATE_FORMATS[:month_date_year] = "%A %d %b"
Time::DATE_FORMATS[:date_month] = "%d %B"
Time::DATE_FORMATS[:day_month_date_year] = "%A, %B %d, %Y"
Time::DATE_FORMATS[:bank] = "%Y%m%d%H%M%S"
Time::DATE_FORMATS[:pretty] = lambda { |time| time.strftime("%a, %b %e at %l:%M") + time.strftime("%p").downcase }
