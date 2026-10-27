-- Задача 6. Активация в первые 7 дней
-- Пользователь активирован, если сделал оплаченный заказ в интервале
-- [signup_date, signup_date + 7 дней), то есть в дни 0–6 включительно.
-- Считаем activation rate по каналам привлечения.

with paid_orders as (
  select
    user_id,
    order_date,
    row_number() over (
      partition by user_id
      order by order_date, order_id
      ) as rn
  from
    orders
  where status = 'paid'
),
first_order as (
  select
    user_id,
    order_date
  from paid_orders
  where rn = 1
)
select
  u.signup_channel,
  count(u.user_id) as users,
  sum(case when julianday(fo.order_date) - julianday(u.signup_date) <= 6 then 1 else 0 end) as activated_users,
  round(1.0 * sum(case when julianday(fo.order_date) - julianday(u.signup_date) <= 6 then 1 else 0 end) / count(u.user_id), 4) as activation_rate
from
  users u
left join
  first_order fo
    on fo.user_id = u.user_id
group by u.signup_channel
order by activation_rate desc
