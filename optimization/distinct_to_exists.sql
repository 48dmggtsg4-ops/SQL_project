-- Задача 6. DISTINCT как запах
-- Исходный запрос использует DISTINCT, чтобы убрать дубли после join-а. Перепишите его так,
-- чтобы зерно было корректным без финального DISTINCT, и сравните план.
--
-- Исходный запрос:
-- SELECT DISTINCT u.user_id, u.channel
-- FROM users u
-- JOIN orders o USING(user_id)
-- JOIN order_items oi USING(order_id)
-- WHERE o.status = 'paid'
--   AND o.order_date >= '2024-05-01'
--   AND o.order_date <  '2024-06-01'

select u.user_id, u.channel
from users u
where exists (
  select 1
  from orders o
  where o.user_id = u.user_id
  and
  o.status = 'paid'
  and
  o.order_date >= '2024-05-01'
  and
  o.order_date <  '2024-06-01'
  and exists (
    select 1
    from order_items oi
    where oi.order_id = o.order_id
  )
);

-- Необходимости в distinct после join нет в новом запросе, так как все user_id будут
-- и так уникальны, так как проверяется условие существования заказа и только в этом случае
-- user_id попадает в итоговую выборку
