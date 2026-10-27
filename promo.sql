-- Задача 4. Промокоды
-- Для каждого не-NULL промокода считаем число оплаченных заказов, выручку и средний чек
-- (на уровне заказа, а не строки order_items). Оставляем промокоды с 20+ оплаченными заказами.

with not_null_promo as (
  select
    order_id,
    promo_code
  from
    orders
  where
    promo_code is not null
    and status = 'paid'
),
revenue_orders as (
  select
    order_id,
    round(sum(quantity * price), 2) as revenue
  from order_items
  group by order_id
)
select
  np.promo_code,
  count(np.order_id) as paid_orders,
  sum(ro.revenue) as revenue,
  round(sum(ro.revenue) / count(np.order_id), 2) as avg_order_value
from
  not_null_promo np
join
  revenue_orders ro
    on ro.order_id = np.order_id
group by np.promo_code
having paid_orders >= 20
