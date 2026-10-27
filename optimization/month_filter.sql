-- Задача 1. Месячный фильтр без функции
-- Дан запрос с substr(order_date, 1, 7). Перепишите фильтр так, чтобы он мог
-- использовать индекс по дате. Создайте подходящий индекс.
-- Время: ~8,8 мс → ~0,6 мс
--
-- Исходный запрос:
-- SELECT COUNT(*) AS paid_orders
-- FROM orders
-- WHERE substr(order_date, 1, 7) = '2024-03'
--   AND status = 'paid'

create index idx_orders_stat_date on orders(status, order_date);

select count(*) as paid_orders
from orders
where order_date >= '2024-03-01'
and
order_date < '2024-04-01'
and
status = 'paid';

-- Мы избавляемся от функции в фильтре where, чтобы ускорить запрос,
-- также создаем индекс по статусу и дате, причем статус первее, чтобы сразу
-- получить только paid заказы, если была б дата первее, пришлость бы проходиться
-- по всему месяцу и отбрасывать status != paid
