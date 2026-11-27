drop table if exists dws.dws_customer;

create table dws.dws_customer (
    customer_id     string comment '客户ID',
    country         string comment '客户所属国家，取该客户出现过的最大国家名（近似）',
    first_order_dt  date   comment '首单日期（正常单·商品行）',
    last_order_dt   date   comment '末单日期（正常单·商品行）',
    order_cnt       bigint comment '累计正常单订单数，0 表示只下过取消单',
    item_qty        bigint comment '累计件数',
    total_gmv       double comment '累计毛额GMV（正常单·商品行）',
    active_days     bigint comment '有下单的天数，不可跨客户相加'
)
stored as orc;

insert overwrite table dws.dws_customer
select
    customer_id,
    max(country) as country,
    min(case when is_formal and is_product then to_date(invoice_date) end) as first_order_dt,
    max(case when is_formal and is_product then to_date(invoice_date) end) as last_order_dt,
    count(distinct case when is_formal and is_product then invoice_no end) as order_cnt,
    nvl(sum(case when is_formal and is_product then quantity end), 0) as item_qty,
    nvl(sum(case when is_formal and is_product then line_amount end), 0) as total_gmv,
    count(distinct case when is_formal and is_product then to_date(invoice_date) end ) as active_days
from dwd.dwd_retail_detail
where customer_id is not null
group by customer_id;