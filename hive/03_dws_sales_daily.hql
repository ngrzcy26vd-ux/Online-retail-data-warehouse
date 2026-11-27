drop table if exists dws.dws_sales_daily;

create table dws.dws_sales_daily(
     dt               date   comment '销售日期',
    order_cnt        bigint comment '正常单订单数（商品行口径，可加）',
    cust_cnt         bigint comment '当日下单客户数（不可跨天相加，去重后会重复计数）',
    item_qty         bigint comment '销售件数（可加）',
    gmv_gross        double comment '毛额GMV=正常单商品行金额合计（可加）',
    gmv_cancel       double comment '取消冲销金额，负数（可加）',
    gmv_net          double comment '净额GMV=毛额+冲销（可加）',
    cancel_order_cnt bigint comment '取消单订单数（可加）'
)
stored as orc;

insert overwrite table dws.dws_sales_daily
select
  to_date(invoice_date) as dt,
  count(distinct case when is_formal and is_product then invoice_no end) as order_cnt,
  count(distinct case when is_formal and is_product then customer_id end) as cust_cnt,
  sum(case when is_formal and is_product then quantity end) as item_qty,
  sum(case when is_formal and is_product then line_amount end ) as gmv_gross,
    sum(case when is_cancel and is_product then line_amount end ) as gmv_cancel,
    sum(case when is_formal and is_product then line_amount end ) + 
    nvl(sum(case when is_cancel and is_product then line_amount end ), 0) as gmv_net,
count(distinct case when is_cancel and is_product then invoice_no end ) as cancel_order_cnt
from dwd.dwd_retail_detail
group by to_date(invoice_date);
