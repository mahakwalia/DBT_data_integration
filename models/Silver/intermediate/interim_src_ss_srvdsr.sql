{{ config(
    materialized="view", 
    database="SRVC_WH", 
    schema="dbo",
    transient=false)
}}


with
    cnsmr_loan_chk as (
        select distinct substring(text, number, 2) as cnsmr_loan_cd
        from {{ source("MASTER", "SPT_VALUES") }} s
        inner join {{ source("LSAMS", "SRVFACT") }} on [key] = 'CONSUMLT'
        where number between 1 and len(text) and number % 2 != 0
    ),

    cte_esc as (
        select distinct loan_nbr, load_dttm
        from {{ source("LSAMS", "SRVESCE") }}
        where escrow_type in ('40', '70', '71', '74')
    ),

    cte_esce(
        select distinct loan_nbr
        from {{ source("LSAMS", "SRVESCE") }}
        where analysis_yn_flag in ('Y')
    )
select *
from {{ source("LSAMS", "SRVDSR") }}
join {{ source("LSAMS", "LSLOAN00") }} on u_loan_num_n = lsln_n

left join {{ source("LSAMS", "BRANDFLP") }} bdflp on srvdsr.u_loan_num_n = bdflp.loan

left join {{ source("LSAMS", "SRVMLD") }} srvmld on u_loan_num = m1loan
left join {{ source("LSAMS", "SRVALT2") }} srvalt2 on u_loan_num_n = a2loan
left join cte_esc esc on u_loan_num_n = esc.loan_nbr
left join cte_esce esce on u_loan_num = esce.loan_nbr
left join
    {{ source("LSAMS", "SRVMBSP") }} srvmbsp
    on srvmbsp.pool = srvdsr.smr110
    and srvdsr.smr070 = srvmbsp.invstr
left join
    {{ source("LSAMS", "SRVMBSP2") }} srvmbsp2
    on srvmbsp2.g2inv = srvdsr.smr070
    and ltrim(rtrim(srvdsr.smr110)) = ltrim(rtrim(srvmbsp2.g2lpool))
left join
    (
        select
            temp1.lbln_n,
            temp1.paperless_stmt_ind as paperless_stmt_ind,
            lsborr00.load_dttm as load_dttm
        from {{ source("LSAMS", "SRVMBSP2") }} lsborr00
        join
            (
                select
                    a.lbln_n,
                    case
                        when a.paperless_stmt_ind = '1' then 'Y' else 'N'
                    end as paperless_stmt_ind
                from
                    (
                        select
                            max(
                                case
                                    when
                                        coalesce(ltrim(rtrim(lbebilfgb)), '0')
                                        in ('', '0', 'A', 'X', 'C', 'D', 'B', 'N', 'Y')
                                    then '0'
                                    else ltrim(rtrim(lbebilfgb))
                                end
                            ) as paperless_stmt_ind,
                            lbln_n
                        from {{ source("LSAMS", "LSBORR00") }} lsborr00
                        group by lbln_n
                    ) a
            ) temp1
            on lsborr00.lbln_n = temp1.lbln_n
    ) lsborr001
    on srvdsr.u_loan_num_n = lsborr001.lbln_n
left join {{ source("LSAMS", "SRVBAL") }} srvbal on u_loan_num_n = srvbal.blloan
