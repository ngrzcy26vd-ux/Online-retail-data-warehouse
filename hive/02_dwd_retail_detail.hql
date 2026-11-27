
drop table if exists dwd.dwd_retail_detail;

create table dwd.dwd_retail_detail(
    invoice_no string comment '订单号',
    stock_code string comment '商品编码',
    description string comment '商品描述',
    quantity int comment '数量',
    invoice_date timestamp comment '订单时间',
    unit_price double comment '单价',
    customer_id string comment '客户ID 缺失为Null',
    country string comment '国家',
    line_amount double comment '行金额=数量*单价',
    is_cancel boolean comment '是否为取消单 C开头为取消单',
    is_bad boolean comment '坏账,商品编码B开头',
    is_stock_record boolean comment '库存,数量小于0且非取消单',
    is_formal       boolean    comment '正常单：以上三类都不沾',
    is_non_product  boolean    comment '非商品行：费用类编码',
    is_product      boolean    comment '商品行'
)
stored as orc;

insert overwrite table dwd.dwd_retail_detail
select 
     t.invoice_no, t.stock_code, t.description, t.quantity, t.invoice_date,
    t.unit_price, t.customer_id, t.country,
    t.quantity * t.unit_price as line_amount,
    t.invoice_no like 'C%' as is_cancel,
    t.stock_code ='B' as is_bad,
    (t.quantity<0 and t.invoice_no not like 'C%') as is_stock_record,
    (t.quantity>=0 and t.invoice_no not like 'C%' and t.stock_code <> 'B') as is_formal,
     (t.stock_code in ('POST','DOT','M','C2','D','S','BANK CHARGES',
                      'AMAZONFEE','CRUK','B')
     or t.stock_code like 'GIFT_0001_%')                               as is_non_product,
     not  (t.stock_code in ('POST','DOT','M','C2','D','S','BANK CHARGES',
                      'AMAZONFEE','CRUK','B')
     or t.stock_code like 'GIFT_0001_%')                               as is_product
from(
    select distinct
        trim(invoice_no ) as invoice_no,
        upper(trim(stock_code)) as stock_code,
        trim(description) as description,
        cast(trim(quantity) as int) as quantity,
        cast(trim(invoice_date) as timestamp) as invoice_date,
        cast(trim(unit_price) as double) as unit_price,
        nullif(trim(customer_id),'') as customer_id,
        trim(country) as country
    from ods.ods_retail_raw
)t;



