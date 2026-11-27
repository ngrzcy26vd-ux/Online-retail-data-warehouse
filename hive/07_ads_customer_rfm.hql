drop table if exists ads.ads_customer_rfm;

create table ads.ads_customer_rfm(
    customer_id string,
    country string,
    last_order_dt date,
    recency_days  int,
    order_cnt     bigint,
    total_gmv     double,
    r_score       int,
    f_score       int,
    m_score       int,
    rfm_segment   string
)
stored as orc;

insert overwrite table ads.ads_customer_rfm
select
    customer_id,country,
    last_order_dt,
    recency_days,
    order_cnt,total_gmv,
    r_score,f_score,m_score,
    case when  r_score is null                          then '未购买'
        when r_score >= 4 and f_score >= 4 and m_score >= 4 then '重要价值'
        when r_score <  4 and f_score >= 4 and m_score >= 4 then '重要保持'
        when r_score >= 4 and f_score <  4 and m_score >= 4 then '重要发展'
        when r_score <  4 and f_score <  4 and m_score >= 4 then '重要挽留'
        when r_score >= 4 and f_score >= 4 and m_score <  4 then '一般价值'
        when r_score <  4 and f_score >= 4 and m_score <  4 then '一般保持'
        when r_score >= 4 and f_score <  4 and m_score <  4 then '一般发展'
        else '一般挽留'
    end as rfm_segment
from(
    select 
    customer_id,country,
    last_order_dt,
    datediff(to_date('2011-12-10'),last_order_dt) as recency_days,
    order_cnt,
    total_gmv,
    ntile(5) over(order by datediff(to_date('2011-12-10'),last_order_dt) desc) as r_score,
    case when
        order_cnt = 1 then 1
        when order_cnt=2 then 2
        when order_cnt between 3 and 4 then 3
        when order_cnt between 5 and 9 then 4
        else 5
    end as f_score,
    ntile(5) over(order by total_gmv asc) as m_score
    from dws.dws_customer
    where customer_id is not null
    and order_cnt > 0
    union all
    select customer_id,country,
    last_order_dt,
    cast(null as int) as recency_days,
    order_cnt,
        total_gmv,
        cast(null as int)    as r_score,
        cast(null as int)    as f_score,
        cast(null as int)    as m_score
    from dws.dws_customer
    where customer_id is not null
    and order_cnt = 0
)t;