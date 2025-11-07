{{ config(materialized='table') }}

with source_data as (

    select * from {{ source('store_data', 'store') }}

)

select *
from source_data
