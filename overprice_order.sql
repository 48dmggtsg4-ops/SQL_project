-- Задача 7. Аномально крупный заказ пользователя
-- Для каждого оплаченного заказа считаем выручку и находим заказы, где она более чем
-- в 3 раза превышает среднюю выручку предыдущих оплаченных заказов этого пользователя.
-- Первый заказ пользователя исключается; среднее считается через AVG(...) OVER (...).

  with paid_orders as (
  select
    user_id,
    order_id,
    order_date,
    row_number() over (
      partition by user_id
      order by order_date, order_id
      ) as rn
  from
    orders
  where status = 'paid'
),
revenue as (
  select
    order_id,
    sum(quantity * price) as order_revenue
  from order_items
  group by order_id
  order by order_revenue desc, order_id
),
with_prev as (
 select
    po.order_id,
    po.user_id,
    po.order_date,
    r.order_revenue,
    avg(r.order_revenue) over (
      partition by po.user_id
      order by po.order_date, po.order_id
      rows between unbounded preceding and 1 preceding
    ) as prev_avg_revenue
  from paid_orders po
  join
    revenue r
      on r.order_id = po.order_id
)
select
  order_id,
  user_id,
  order_date,
  order_revenue,
  prev_avg_revenue
from with_prev
group by order_id
having
  order_revenue > prev_avg_revenue * 3
order by order_date, order_id
