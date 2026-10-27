-- Задача 3. JOIN после предварительной агрегации
-- Оптимизируйте запрос выручки по каналам: сначала агрегируйте order_items до уровня
-- заказа (grain = order_id), затем соединяйте с orders и users.
-- Время: ~173 мс → ~159 мс
--
-- Исходный запрос:
-- SELECT u.channel, SUM(oi.quantity * oi.price) AS revenue
-- FROM order_items oi
-- JOIN orders o USING(order_id)
-- JOIN users u USING(user_id)
-- WHERE o.status = 'paid'
--   AND o.order_date >= '2024-01-01'
--   AND o.order_date <  '2024-07-01'
-- GROUP BY u.channel

with order_revenue as (
  select
    order_id,
    sum(quantity * price) as revenue
  from order_items
  group by order_id
)
select
  u.channel,
  sum(r.revenue) as revenue
from order_revenue r
join
orders o
  on o.order_id = r.order_id
join
users u
  on u.user_id = o.user_id
where o.status = 'paid'
and
o.order_date >= '2024-01-01'
and
o.order_date <  '2024-07-01'
group by u.channel;

-- Такой способ предагрегации данных лучше, так как уже есть группировка прибыли по
-- заказам, а не приходится один и тот же айди несолько раз с таблицами join-ить
