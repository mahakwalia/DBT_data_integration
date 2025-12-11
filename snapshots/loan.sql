-- unq_key_txt is a combination of Loan_nbr &
{% snapshot loan %}
    {{
      config(
        unique_key='unq_key_txt', 
        strategy='check',
        check_cols=[
            'escrw_ind',
            'escrw_bal_amt',
            'fha_va_case_nbr',
            'note_amt',
            'note_rt_pct',
            'loan_sts_cd',
            'prod_cd',
            'loan_mtr_dt',
            'securitized_dt'
        ],
        invalidate_hard_deletes=True
      )
    }}

with
    final as (
        select
            null as prin_pymt_alow_ind,
            escrw_ind,
            temp_cpy_loan_key.escrw_bal_amt as escrw_bal_amt,
            null as recur_pymt_alow_ind,
            srvc_fee_amt,
            late_chrg_grace_prd_day_cnt,
            trim(temp_cpy_loan_key.fha_va_case_nbr) as fha_va_case_nbr,
            null as mkt_ltv,
            temp_cpy_loan_key.escrw_advn_amt as escrw_advn_amt,
            trim(temp_cpy_loan_key.int_meth_cd) as int_mth_cd,
            temp_cpy_loan_key.note_amt as note_amt,
            temp_cpy_loan_key.note_rt_pct as note_pct_rt,
            trim(temp_cpy_loan_key.late_chrg_cd) as late_chrg_cd,
            loan_acq_mth_cd,
            neg_amz_ind,
            trim(temp_cpy_loan_key.invstr_cd) as invstr_cd,
            mi_prem_pct_rt,
            mtg_insmt,
            mth_past_due,
            cast(current_timestamp() as timestamp_ntz) as aud_upd_dttm,
            
            last_due_dt,
            trim(temp_cpy_loan_key.loan_sts_cd) as loan_sts_cd,
            mi_prem_fnce_ind_cd,
            temp_cpy_loan_key.mth_late_chrg_amt as mth_late_chrg_amt,
            msa_txt,
            mtg_type,
            temp_cpy_loan_key.escrw_bal_unencb_amt as escrw_bal_unencb_amt,
            loan_age,
            min_mers_nbr,
            bkpt_ind,
            curr_cltv,
            to_date(temp_cpy_loan_key.last_pymt_rcv_dt) as last_pymt_rcvd_dt,
            to_date(temp_cpy_loan_key.nxt_pymt_due_dt) as nxt_pymt_due_dt,
            rmn_term,
            null as wsite_pymt_alow_ind,
            yr_to_dt_whld,
            tot_anul_fee_bill_amt,
            null as tot_owed_amt,
            null as txn_fee_elg_cd,
            temp_cpy_loan_key.loan_nbr
            || '~'
            || 'lsm'
            || '~'
            || trim(coalesce(temp_cpy_loan_key.brnd_nm, '<null>')) as unq_key_txt,
            temp_cpy_loan_key.upb_amt as upb_amt,
            wsite_accs_alow_ind,
            late_chrg_src_cd,
            loan_type_ind,
            stop_advn_flg,
            null as aud_cre_by_nm,
            cast(current_timestamp() as timestamp_ntz) as aud_cre_dttm,
            bln_ind,
            dschrg_bkpt_ind,
            case
                when temp_cpy_loan_key.last_escrw_anls_dt is null
                then null
                when try_to_date(temp_cpy_loan_key.last_escrw_anls_dt) is not null
                then to_date(temp_cpy_loan_key.last_escrw_anls_dt)
                else null
            end as last_escrow_anls_dt,
            dbt_valid_from  as eff_dttm,
            dbt_valid_to as end_dttm,
            CASE WHEN dbt_valid_to IS NULL THEN 'Y' ELSE 'N' END  as curr_ind,
            flood_ins_rqr_flg,
            invstr_loan_nbr,
            reo_ind,
            temp_cpy_loan_key.loan_key as loan_key,
            trim(temp_cpy_loan_key.loan_type_cd) as loan_type_cd,
            curr_ltv,
            int_only_term,
            null as ivr_pymt_alow_ind,
            mi_pct_cvr_amt,
            null as mkt_cltv,
            trim(temp_cpy_loan_key.prod_cd_desc) as prod_cd_desc,
            null as escrw_pymt_alow_ind,
            escrw_advn_by_invstr,
            mi_ind,
            min_hzrd_rt_rqr,
            non_sfcnt_fund_chrg_amt,
            paperless_stmt_ind,
            wi_tax_opt,
            amz_term,
            arm_ind,
            temp_cpy_loan_key.pymt_appl_pln_nbr as pymt_appl_pln_nbr,
            
            escrw_orgnl_pymt,
            hghr_prc_mtg_loan_ind,
            lsams_rfd_cd,
            int_only_ind,
            trim(temp_cpy_loan_key.prod_cd) as prod_cd,
            to_date(temp_cpy_loan_key.loan_mtr_dt) as loan_mtr_dt,
            temp_cpy_loan_key.securitized_dt as securitized_dt,
            frst_pymt_due_dt,
            grt_fee,
            cnsmr_loan_flg,
            rgst_with_mers_flg,
            '9999' as etl_batch_id,
            invstr_pool_nbr,
            case
                when temp_cpy_loan_key.fha_case_asgn_dt is null
                then null
                when
                    try_to_date(temp_cpy_loan_key.fha_case_asgn_dt, 'mm-dd-yyyy')
                    is not null
                then try_to_date(temp_cpy_loan_key.fha_case_asgn_dt, 'mm-dd-yyyy')
                else null
            end as fha_case_asgn_dt,
            last_actv_dt,
            orgnl_cltv,
            'lsm' as sor_cd,
            frcls_ind,
            trim(temp_cpy_loan_key.pool_id) as pool_id,
            late_chrg_pct_rt,
            null as aud_upd_by_nm,
            lien_pstn,
            temp_cpy_loan_key.brnd_nm as brnd_nm,
            tot_advn_bal_amt
        from {{ ref("interim_cpy_loan_key") }} temp_cpy_loan_key
        left join
            {{ ref("interim_copy_58") }} temp_copy_58
            on temp_copy_58.loan_key = temp_cpy_loan_key.loan_key
    )

select *
from final

{% endsnapshot %}