drop table if exists dws.dws_product;

create table dws.dws_product (
    stock_code    string comment '商品编码',
    description   string comment '商品描述，取该编码出现次数靠前的那个（近似）',
    first_sold_dt date   comment '首次售出日期',
    last_sold_dt  date   comment '末次售出日期',
    order_cnt     bigint comment '出现过该商品的订单数，不可跨商品相加',
    cust_cnt      bigint comment '买过该商品的客户数，不可跨商品相加',
    item_qty      bigint comment '累计销量',
    total_gmv     double comment '累计销售额'
)
stored as orc;

insert overwrite table dws.dws_product
select
    stock_code,
    max(description) as description,
    min(case when is_formal and is_product then to_date(invoice_date) end) as first_sold_dt,
    max(case when is_formal and is_product then to_date(invoice_date) end) as last_sold_dt,
    count(distinct case when is_formal and is_product then invoice_no end) as order_cnt,
    count(distinct case when is_formal and is_product then customer_id end) as cust_cnt,
    nvl(sum(case when is_formal and is_product then quantity end), 0) as item_qty,
    nvl(sum(case when is_formal and is_product then line_amount end), 0) as total_gmv
from dwd.dwd_retail_detail
where is_formal and is_product
group by stock_code