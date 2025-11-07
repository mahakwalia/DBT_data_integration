{{ config(
    materialized='table',
    pre_hook= ["{{create_schema('test')}}"]
) }}

{% set rating_categories = ["ss_net_paid",
                            "ss_net_paid_inc_tax",
                            "ss_net_profit"] %}

with source_data as (

    
    SELECT ss_item_sk,ss_sold_date_sk,
    {%- for col_name in rating_categories -%}
    AVG({{ col_name }}) as {{ column_name }}_average
    {%- if not loop.last  -%} 
        , 
    {%- endif -%}
    {%- endfor -%}
    
    FROM {{ source('store_data', 'store_sales') }}  
    GROUP BY 1,2
)

select ss.*, i.i_category, i.i_product_name
from source_data ss 
left join {{ source('store_data', 'item') }} i 
    on ss.ss_item_sk = i.i_item_sk

