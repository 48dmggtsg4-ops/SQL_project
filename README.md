# SQL-аналитика интернет-магазина

Учебный проект: SQL-запросы (SQLite) к данным интернет-магазина. Пользователи, товары, заказы и поведенческие события
анализируются с помощью CTE, оконных функций и подзапросов. Отдельно собраны задачи по оптимизации запросов.

## Возможности

- Сегментирует пользователей по числу оплаченных заказов и считает средний и суммарный LTV каждого сегмента.
- Ранжирует товары внутри категории по месячной выручке и отбирает топ-3.
- Находит пользователей, которые смотрели категорию, но ничего в ней не купили, и заказы, аномально крупные для конкретного покупателя.
- Считает продуктовые метрики: эффективность промокодов, repeat-rate по городам, активацию в первые 7 дней по каналам привлечения.
- Показывает приёмы оптимизации (папка `optimization/`): составные и покрывающие индексы, фильтры, которые могут использовать индекс, `EXISTS` вместо `DISTINCT`, агрегацию перед `JOIN`.

## Требования

- SQLite CLI (`sqlite3`) 3.33+. На macOS уже установлен. На Ubuntu/Debian: `sudo apt install sqlite3`.
- Git, чтобы скачать репозиторий.

## Установка

1. Скачайте репозиторий:

```bash
git clone https://github.com/48dmggtsg4-ops/SQL_project.git
```

```bash
cd SQL_project
```

2. Соберите базу `shop.db` из CSV-файлов в папке `tables/`:

```bash
sqlite3 shop.db <<'EOF'
CREATE TABLE users (user_id INTEGER, signup_date TEXT, signup_channel TEXT, city TEXT);
CREATE TABLE products (product_id INTEGER, category TEXT, brand TEXT, base_price REAL);
CREATE TABLE orders (order_id INTEGER, user_id INTEGER, order_date TEXT, status TEXT, promo_code TEXT);
CREATE TABLE order_items (order_id INTEGER, product_id INTEGER, quantity INTEGER, price REAL);
CREATE TABLE events (event_id INTEGER, user_id INTEGER, event_time TEXT, event_type TEXT, product_id INTEGER);
.import --csv --skip 1 tables/users.csv users
.import --csv --skip 1 tables/products.csv products
.import --csv --skip 1 tables/orders.csv orders
.import --csv --skip 1 tables/order_items.csv order_items
.import --csv --skip 1 tables/events.csv events
UPDATE orders SET promo_code = NULL WHERE promo_code = '';
EOF
```

Таблицы создаются с типами колонок заранее, потому что `.import` в несуществующую таблицу делает все колонки текстовыми.
`UPDATE` в конце превращает пустые промокоды в `NULL`, как в исходных данных.

## Использование

Каждый файл `<имя>.sql` в корне — одна аналитическая задача. Условие записано в комментарии в начале файла,
ожидаемый результат лежит рядом в `<имя>.csv`.

Запуск одной задачи:

```bash
sqlite3 -box shop.db < promo.sql
```

Ожидаемый результат:

```
╭────────────┬─────────────┬────────────┬─────────────────╮
│ promo_code │ paid_orders │  revenue   │ avg_order_value │
╞════════════╪═════════════╪════════════╪═════════════════╡
│ SUMMER15   │         223 │ 3446366.39 │        15454.56 │
│ VIP20      │         116 │ 1732825.06 │        14938.15 │
│ WELCOME10  │         331 │ 4820101.93 │        14562.24 │
╰────────────┴─────────────┴────────────┴─────────────────╯
```

Запуск всех задач по очереди:

```bash
for f in *.sql; do echo "== $f"; sqlite3 -box shop.db < "$f"; done
```

| Файл | Задача |
|---|---|
| `LTV_segments.sql` | LTV по сегментам пользователей |
| `top_3.sql` | Топ-3 товара в категории по месячной выручке |
| `look_not_paid.sql` | Смотрели категорию, но не покупали |
| `promo.sql` | Промокоды: заказы, выручка, средний чек |
| `repeat_rate.sql` | Города с repeat-rate выше среднего |
| `7d_activ.sql` | Активация в первые 7 дней по каналам |
| `overprice_order.sql` | Заказы в 3+ раза крупнее среднего у покупателя |

### Оптимизация (`optimization/`)

В каждом файле есть условие задачи, индекс (если нужен), итоговый запрос и время до и после оптимизации.
Запросы рассчитаны на другой, более крупный набор данных: 12 000 пользователей, 65 000 заказов, 180 000 событий, колонка `users.channel`.
**Этих данных в репозитории нет.** На таблицах из `tables/` файлы `preaggregation.sql` и `distinct_to_exists.sql` падают с ошибкой
`no such column: u.channel`, а остальные выполняются, но не на тех данных, на которых замерялось время.

[УТОЧНИТЬ: откуда взять набор данных для `optimization/` — добавить CSV в репозиторий или скрипт генерации]

## Лицензия

MIT
