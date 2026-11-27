create external table if not exists ods.ods_retail_raw (
    invoice_no string comment '原始InvoiceNo C开头为取消单/记贷',
    stock_code string comment '原始StockCode, 含字母费用码与 DCGS/PADS 真商品码',
    description string comment '商品描述, 6,035 行带双引号包裹',
    quantity string comment '原始数量 ,含负数',
    invoice_date string comment '原始时间字符串 yyyy-MM-dd HH:mm:ss',
    unit_price string comment '原始单价 含0和负数',
    customer_id string comment '原始客户 ',
    country string comment '原始国家名'
)
row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties (
    "separatorChar" = ",",
    "quoteChar"     = '"',
    "escapeChar"    = "\\"
)
stored as textfile
LOCATION '/data/retail/raw';


