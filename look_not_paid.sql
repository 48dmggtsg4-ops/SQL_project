-- Задача 3. Просматривали категорию, но не покупали её
-- Находим пары user_id + category, где пользователь смотрел товары категории
-- (events.event_type = 'product_view'), но ни разу не купил оплаченный товар этой категории.

with paid_orders as (
  select
    o.user_id,
    p.category
  from
    orders o
  join
    order_items oi
      on oi.order_id = o.order_id
  join
    products p
      on p.product_id = oi.product_id
  where status = 'paid'
  group by o.user_id, p.category
),
view_products as (
  select
    e.user_id,
    e.product_id,
    p.category
  from
    events e
  join
    products p
      on p.product_id = e.product_id
  where e.event_type = 'product_view'
)
select
  vp.user_id,
  vp.category
from view_products vp
where not exists (
  select
    1
  from paid_orders po
  where
    po.user_id = vp.user_id
    and po.category = vp.category
  )
group by vp.user_id, vp.category
order by vp.user_id, vp.category
