-- Задача 2. Top-3 товара внутри категории по месячной выручке
-- Для каждого месяца и категории находим 3 товара с максимальной оплаченной выручкой.
-- Ранжирование оконной функцией, при равной выручке побеждает меньший product_id.

with monthly_revenue as (
  select
    substr(o.order_date, 1, 7) as month,
    p.category,
    p.product_id,
    round(sum(oi.quantity * oi.price), 2) as revenue
  from
    orders o
  join
    order_items oi
      on oi.order_id = o.order_id
      and o.status = 'paid'
  join
    products p
      on oi.product_id = p.product_id
  group by month, p.product_id, p.category
  ),
  ranked_products as (
    select
      month,
      product_id,
      revenue,
      category,
      row_number() over (
        partition by month, category
        order by revenue desc, product_id
        ) as rank_in_category
    from
      monthly_revenue
  )

  select
    month,
    category,
    product_id,
    revenue,
    rank_in_category
  from ranked_products
  where rank_in_category <= 3
  order by
    month, category, rank_in_category
