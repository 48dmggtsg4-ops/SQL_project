-- Задача 5. Последнее событие пользователя
-- Оптимизируйте запрос, который достает последние 50 событий конкретного
-- пользователя по времени.
-- Время: ~19,4 мс → ~0,8 мс

create index idx_events_user_time on events(user_id, event_time);

SELECT event_id, user_id, event_time, event_type
FROM events
WHERE user_id = 777
ORDER BY event_time DESC
LIMIT 50;

-- Сначала выберутся все юзеры с айди 777, потом уже среди них первые 50, так как
-- есть сортировка по event_time
