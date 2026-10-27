-- Задача 5. Города с repeat-rate выше среднего
-- Repeat-rate — доля покупателей города с 2+ оплаченными заказами
-- (покупатель — пользователь с хотя бы одним оплаченным заказом).
-- Выводим города, где repeat-rate выше общего по всем покупателям.

with buyers as (
  select
    user_id,
    count(order_id) as amount_orders
  from orders
  where status = 'paid'
  group by user_id
  having amount_orders >= 1
),
city_stats as (
  select
    u.city,
    count(b.user_id) as buyers,
    sum(case when b.amount_orders >= 2 then 1 else 0 end) as repeat_buyers,
    round(
      1.0 * sum(case when b.amount_orders >= 2 then 1 else 0 end) / count(b.user_id),
      4
    ) as repeat_rate,
    round(
      1.0 * sum(sum(case when b.amount_orders >= 2 then 1 else 0 end)) over()
      / sum(count(b.user_id)) over(),
      4
    ) as overall_repeat_rate
  from buyers b
  join users u
    on u.user_id = b.user_id
  group by u.city
)
select
  city,
  buyers,
  repeat_buyers,
  repeat_rate,
  overall_repeat_rate
from
  city_stats
group by city
having repeat_rate > overall_repeat_rate
order by repeat_rate desc
