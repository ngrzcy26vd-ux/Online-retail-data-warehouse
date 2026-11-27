drop table if exists dws.dws_country;

create table dws.dws_country (
    country   string comment '国家',
    order_cnt bigint comment '订单数（可加，相加=20538）',
    cust_cnt  bigint comment '客户数（不可加，有8个客户跨2国）',
    item_qty  bigint comment '销量',
    total_gmv double comment '销售额'
)
stored as orc;

insert overwrite table dws.dws_country
select
    country,
    count(distinct case when is_formal and is_product then invoice_no end) as order_cnt,
    count(distinct case when is_formal and is_product then customer_id end) as cust_cnt,
    nvl(sum(case when is_formal and is_product then quantity end), 0) as item_qty,
    nvl(sum(case when is_formal and is_product then line_amount end), 0) as total_gmv
from dwd.dwd_retail_detail
where is_product and is_formal and country is not null
group by country;