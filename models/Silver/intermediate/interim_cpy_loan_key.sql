{{ config(materialized="view", database="SRVC_WH", schema="dbo", transient=false) }}


with
    cte_pv3 as (
        select propertyid, max(valuationdate) as valuationdate
        from {{ source("PVM", "TBL_VALUATION") }}
        group by propertyid
    ),
    cte_pv4 as (
        select pv2.propertyid, pv2.asisvalue
        from {{ source("PVM", "TBL_VALUATION") }} pv2, cte_pv3 pv3

        where pv2.propertyid = pv3.propertyid and pv2.valuationdate = pv3.valuationdate
    ),
    cte_pv as (
        select pv1.loannumber, pv4.asisvalue
        from {{ source("PVM", "TBL_PROPERTY") }} pv1, cte_pv4 pv4

        where pv1.id = pv4.propertyid
    ),

    cte_ss_src_pvm as (select loannumber, asisvalue, 1 as dummy from cte_pv pv),

    final as (
        select
            temp_src_ss_srvdsr.escrw_ind as escrw_ind,
            temp_src_ss_srvdsr.arm_ind as arm_ind,
            temp_src_ss_srvdsr.aud_cre_dttm as aud_cre_dttm,
            temp_src_ss_srvdsr.aud_upd_by_nm as aud_upd_by_nm,
            temp_src_ss_srvdsr.last_due_dt as last_due_dt,
            temp_src_ss_srvdsr.loan_type_cd as loan_type_cd,
            temp_src_ss_srvdsr.brnd_nm as brnd_nm,
            temp_src_ss_srvdsr.int_only_term as int_only_term,
            temp_src_ss_srvdsr.mi_prem_fnce_ind_cd as mi_prem_fnce_ind_cd,
            temp_src_ss_srvdsr.neg_amz_ind as neg_amz_ind,
            temp_src_ss_srvdsr.cnsmr_loan_flg as cnsmr_loan_flg,
            temp_src_ss_srvdsr.invstr_loan_nbr as invstr_loan_nbr,
            temp_src_ss_srvdsr.loan_sts_cd as loan_sts_cd,
            temp_src_ss_srvdsr.paperless_stmt_ind as paperless_stmt_ind,
            temp_src_ss_srvdsr.late_chrg_grace_prd_day_cnt
            as late_chrg_grace_prd_day_cnt,
            temp_src_ss_srvdsr.late_chrg_src_cd as late_chrg_src_cd,
            temp_src_ss_srvdsr.mtg_type as mtg_type,
            temp_src_ss_srvdsr.int_meth_cd as int_meth_cd,
            temp_src_ss_srvdsr.escrw_advn_by_invstr as escrw_advn_by_invstr,
            temp_src_ss_srvdsr.min_mers_nbr as min_mers_nbr,
            temp_src_ss_srvdsr.aud_cre_by_nm as aud_cre_by_nm,
            temp_src_ss_srvdsr.last_actv_dt as last_actv_dt,
            temp_src_ss_srvdsr.mi_prem_rt_pct as mi_prem_rt_pct,
            temp_src_ss_srvdsr.amz_term as amz_term,
            temp_src_ss_srvdsr.last_escrw_anls_dt as last_escrw_anls_dt,
            temp_src_ss_srvdsr.loan_type_ind as loan_type_ind,
            ss_src_pvm.loan_sts_cd as curr_ltv,
            temp_src_ss_srvdsr.escrw_advn_amt as escrw_advn_amt,
            ref_zip_to_fip.msa_txt as msa_txt,
            temp_src_ss_srvdsr.note_amt as note_amt,
            temp_src_ss_srvdsr.escrw_bal_unencb_amt as escrw_bal_unencb_amt,
            temp_src_ss_srvdsr.lsams_rfd_cd as lsams_rfd_cd,
            temp_src_ss_srvdsr.prod_cd_desc as prod_cd_desc,
            temp_src_ss_srvdsr.pymt_appl_pln_nbr as pymt_appl_pln_nbr,
            temp_src_ss_srvdsr.rgst_with_mers_flg as rgst_with_mers_flg,
            temp_src_ss_srvdsr.smr110 as smr110,
            temp_src_ss_srvdsr.bln_ind as bln_ind,
            temp_src_ss_srvdsr.fha_case_asgn_dt as fha_case_asgn_dt,
            temp_src_ss_srvdsr.note_rt_pct as note_rt_pct,
            temp_src_ss_srvdsr.rmn_term as rmn_term,
            temp_src_ss_srvdsr.securitized_dt as securitized_dt,
            temp_src_ss_srvdsr.sma300 as sma300,
            temp_src_ss_srvdsr.smm030 as smm030,
            temp_src_ss_srvdsr.smm040 as smm040,
            temp_src_ss_srvdsr.smm050 as smm050,
            temp_src_ss_srvdsr.smm090 as smm090,
            temp_src_ss_srvdsr.smr070 as smr070,
            temp_src_ss_srvdsr.srvc_fee_amt as srvc_fee_amt,
            temp_src_ss_srvdsr.stop_advn_flg as stop_advn_flg,
            temp_src_ss_srvdsr.tot_advn_bal_amt as tot_advn_bal_amt,
            temp_src_ss_srvdsr.tot_anul_fee_billed_amt as tot_anul_fee_billed_amt,
            temp_src_ss_srvdsr.truncate_flag as truncate_flag,
            temp_src_ss_srvdsr.upb_amt as upb_amt,
            temp_src_ss_srvdsr.wi_tax_opt as wi_tax_opt,
            temp_src_ss_srvdsr.yr_to_dt_whld as yr_to_dt_whld,
            temp_src_ss_srvdsr.aud_upd_dttm as aud_upd_dttm,
            temp_src_ss_srvdsr.loan_acq_meth_cd as loan_acq_meth_cd,
            temp_src_ss_srvdsr.loan_age as loan_age,
            temp_src_ss_srvdsr.loan_nbr as loan_nbr,
            temp_src_ss_srvdsr.late_chrg_cd as late_chrg_cd,
            temp_src_ss_srvdsr.mi_pct_cvr_amt as mi_pct_cvr_amt,
            temp_src_ss_srvdsr.hghr_prc_mtg_loan_ind as hghr_prc_mtg_loan_ind,
            temp_src_ss_srvdsr.invstr_pool_nbr as invstr_pool_nbr,
            temp_src_ss_srvdsr.last_pymt_rcv_dt as last_pymt_rcv_dt,
            temp_src_ss_srvdsr.late_chrg_rt_pct as late_chrg_rt_pct,
            temp_src_ss_srvdsr.loan_mtr_dt as loan_mtr_dt,
            temp_src_ss_srvdsr.non_sfcnt_fund_chrg_amt as non_sfcnt_fund_chrg_amt,
            temp_src_ss_srvdsr.mtg_insmt as mtg_insmt,
            temp_src_ss_srvdsr.lien_pstn as lien_pstn,
            temp_src_ss_srvdsr.fha_va_case_nbr as fha_va_case_nbr,
            temp_src_ss_srvdsr.flood_ins_rqr_flg as flood_ins_rqr_flg,
            temp_src_ss_srvdsr.int_only_ind as int_only_ind,
            temp_src_ss_srvdsr.prod_cd as prod_cd,
            temp_src_ss_srvdsr.orig_cltv as orig_cltv,
            temp_src_ss_srvdsr.pool_id as pool_id,
            temp_src_ss_srvdsr.invstr_cd as invstr_cd,
            temp_src_ss_srvdsr.min_hzrd_rt_rqr as min_hzrd_rt_rqr,
            temp_src_ss_srvdsr.mth_past_due as mth_past_due,
            temp_src_ss_srvdsr.escrw_bal_amt as escrw_bal_amt,
            temp_src_ss_srvdsr.frst_pymt_due_dt as frst_pymt_due_dt,
            temp_src_ss_srvdsr.grt_fee as grt_fee,
            temp_src_ss_srvdsr.mth_late_chrg_amt as mth_late_chrg_amt,
            loan_nbr_cross_ref.loan_key as loan_key,
            temp_src_ss_srvdsr.nxt_pymt_due_dt as nxt_pymt_due_dt,
            temp_src_ss_srvdsr.curr_cltv | ss_src_pvm.curr_cltv as curr_cltv,
            temp_src_ss_srvdsr.escrw_orgnl_pymt as escrw_orgnl_pymt,
            temp_src_ss_srvdsr.mi_ind as mi_ind

        from {{ ref("interim_src_ss_srvdsr") }} temp_src_ss_srvdsr
        inner join
            {{ source("LSAMS", "LOAN_NBR_CROSS_REF") }}
            on temp_src_ss_srvdsr.loan_nbr = loan_nbr_cross_ref.loan_nbr
            and temp_src_ss_srvdsr.brnd_nm = loan_nbr_cross_ref.brnd_nm
        join
            {{ source("SRVC_WH", "REF_ZIP_TO_FIP") }} ref_zip_to_fip
            on ref_zip_to_fip.zip_code = temp_src_ss_srvdsr.prop_zip
        left join
            cte_ss_src_pvm ss_src_pvm

            on ss_src_pvm.loannumber = temp_src_ss_srvdsr.loan_nbr
