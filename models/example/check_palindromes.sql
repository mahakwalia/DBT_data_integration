{{ config(
    materialized='view'
) }}

SELECT
    ss_item_sk,
    {{ is_palindrome('ss_item_sk') }} AS is_palindrome_check
FROM
    {{ ref('my_first_dbt_model') }} 
