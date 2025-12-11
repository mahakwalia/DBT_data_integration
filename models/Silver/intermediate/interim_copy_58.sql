{{ config(materialized="view", database="SRVC_WH", schema="dbo", transient=false) }}

with
    cte_lsbkcas00 as (
        select
            cast(bcloannbr as varchar(16)) as loan_nbr,
            cast(lsl.lsbrand as varchar(16)) as brnd_nm,
            cast(bcchpfiled as varchar(2)) as file_chap_cd,
            cast(bcstatus as char(1)) as case_sts_cd,
            case
                when bcclosedt = 0
                then null
                else cast(cast(bcclosedt as varchar(8)) as date)
            end as case_close_dt,
            cast(1 as smallint) as key1,
            lsb.loan_key
        from {{ source("LSAMS", "LSBKCAS00") }} lsb
        join {{ source("LSAMS", "LSLOAN00") }} lsl on lsl.lsln_n = lsb.bcloannbr
        where coalesce(bcclosedt, 0) = 0 and ltrim(rtrim(bcstatus)) <> 'C'

        qualify
            rank() over (partition by bcloannbr, bccasenbr order by load_dttm desc) = 1
    ),

    cte_loan_msg_cd as (
        select loan_key, msg_sq_nbr, msg_cd from {{ source("LSAMS", "LOAN_MSG_CD") }}
    ),

    final as (

        select if loan_key is null
        then 'N'
        else
            'Y' as loan_key,
            max(
                if trim(if msg_cd is null then 'ZZ' else msg_cd) = '17'
                or trim(if msg_cd is null then 'ZZ' else msg_cd) = '27'
                or trim(if msg_cd is null then 'ZZ' else msg_cd) = '43'
                then 'Y'
                else 'N'
            ) as dschrg_bkpt_ind,
            max(
                if trim(if msg_cd is null then 'ZZ' else msg_cd) = '06'
                then 'Y'
                else 'N'
            ) as reo_ind,
            max(
                if trim(if msg_cd is null then 'ZZ' else msg_cd) = '08'
                then 'Y'
                else 'N'
            ) as actv_frcls_ind,
            if key1 is null
        then 'N'
        else
            'Y' as bkpt_ind
            case
                when
                    min(
                        case
                            when
                                (
                                    trim(
                                        case
                                            when loan_msg_cd.msg_cd is null
                                            then 'ZZ'
                                            else loan_msg_cd.msg_cd
                                        end
                                    )
                                    = '06'
                                    or trim(
                                        case
                                            when loan_msg_cd.msg_cd is null
                                            then 'ZZ'
                                            else loan_msg_cd.msg_cd
                                        end
                                    )
                                    = '85'
                                    or trim(
                                        case
                                            when loan_msg_cd.msg_cd is null
                                            then 'ZZ'
                                            else loan_msg_cd.msg_cd
                                        end
                                    )
                                    = '49'
                                    or temp_cpy_loan_key.smr110 = 3
                                    or trim(temp_cpy_loan_key.smr070) = '995'
                                    or trim(temp_cpy_loan_key.smm090) = 'F'
                                    or trim(
                                        case
                                            when loan_msg_cd.msg_cd is null
                                            then 'ZZ'
                                            else loan_msg_cd.msg_cd
                                        end
                                    )
                                    = '91'
                                    or trim(
                                        case
                                            when loan_msg_cd.msg_cd is null
                                            then 'ZZ'
                                            else loan_msg_cd.msg_cd
                                        end
                                    )
                                    = '90'
                                    or (
                                        temp_cpy_loan_key.loan_type_cd = '30'
                                        and temp_cpy_loan_key.lien_pstn = 2
                                    )
                                )
                            then 'N'
                            else 'Y'
                        end
                    )
                    = 'Y'
                    and (
                        case
                            when
                                (case when key1 is null then 'N' else 'Y' end) = 'Y'
                                and (lsbkcas00.file_chap_cd in ('07', '11', '12', '13'))
                            then 'Y'
                            when (case when key1 is null then 'N' else 'Y' end) = 'N'
                            then 'Y'
                            else 'N'
                        end
                    )
                    = 'Y'
                    or temp_cpy_loan_key.smr110 = 3
                then 'Y'
                else 'N'
            end as website_accs_alow_ind

        from temp_cpy_loan_key
        left join cte_lsbkcas00 on temp_cpy_loan_key.loan_key = cte_lsbkcas00.loan_key

        inner join

            {{ source("LSAMS", "LOAN_NBR_CROSS_REF") }} loan_nbr_cross_ref
            on loan_nbr_cross_ref.loan_nbr = cte_lsbkcas00.loan_nbr
            and loan_nbr_cross_ref.brnd_nm = cte_lsbkcas00.brnd_nm

        left join
            cte_loan_msg_cd on cte_loan_msg_cd.loan_key = temp_cpy_loan_key.loan_key
        group by
            loan_nbr_cross_ref.loan_key,
            cte_lsbkcas00.key1,
            cte_loan_msg_cd.msg_cd,
            cte_lsbkcas00.file_chap_cd,
            temp_cpy_loan_key.smr110,
            temp_cpy_loan_key.smr070,
            temp_cpy_loan_key.smm090,
            temp_cpy_loan_key.loan_type_cd,
            temp_cpy_loan_key.lien_pstn
    )

select *
from final
