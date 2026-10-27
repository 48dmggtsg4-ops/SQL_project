-- Задача 4. NOT EXISTS и индекс
-- Найдите пользователей, у которых нет событий purchase. Подберите индекс
-- для коррелированного подзапроса и проверьте план.
-- Время: без индекса не замерялось → ~14 мс с индексом

create index idx_event_user_status on events(user_id, event_type);

SELECT u.user_id
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM events e
  WHERE e.user_id = u.user_id
    AND e.event_type = 'purchase'
);

-- Используем индекс по user_id, так как через него идет соединение двух таблиц,
-- а event_type оставит нам нужные строки
