Fabricator(:packing_list) do
  distributor
  date Date.current - 1.day
end
