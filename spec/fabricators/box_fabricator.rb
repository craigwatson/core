Fabricator(:box) do
  distributor
  name { sequence(:name) { |i| "Box #{i}" } }
  description { "A description about this box." }
  price 10
  extras_limit 0
end

Fabricator(:customisable_box, from: :box) do
  dislikes true
  extras_limit 5
end
