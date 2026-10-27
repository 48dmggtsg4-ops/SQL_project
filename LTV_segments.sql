-- Задача 1. LTV-сегменты
-- Для каждого пользователя считаем оплаченный LTV и число оплаченных заказов,
-- делим на сегменты (no_paid_orders, one_order, 2_3_orders, 4_plus_orders)
-- и выводим размер сегмента, средний и суммарный LTV.
-- Пользователи без оплаченных заказов тоже входят в расчёт (LTV = 0).

with segm_table as (
  select
    u.user_id,
    count(distinct o.order_id) as total_orders,
    case
      when count(distinct o.order_id) = 1 then 'one_order'
      when count(distinct o.order_id) between 2 and 3 then '2_3_orders'
      when count(distinct o.order_id) >= 4 then '4_plus_orders'
      else 'no_paid_orders'
  end as segment
    from
      users u
    left join
      orders o
        on u.user_id = o.user_id
        and o.status = 'paid'
    group by u.user_id
    )
select
  st.segment,
  count(distinct st.user_id) as users,
  case
    when sum(oi.quantity * oi.price) is null then 0.00
    else round(sum(oi.quantity * oi.price) / count(distinct st.user_id), 2)
    end as avg_ltv,
  case
    when sum(oi.quantity * oi.price) is null then 0.00
    else round(sum(oi.quantity * oi.price), 2)
    end as total_ltv
  from
    segm_table st
  left join
    orders o
      on st.user_id = o.user_id
      and o.status = 'paid'
  left join
    order_items oi
      on oi.order_id = o.order_id
  group by st.segment
  order by users desc
