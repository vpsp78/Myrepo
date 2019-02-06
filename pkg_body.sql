--------------------------------------------------------
--  File created - Thursday-October-04-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body MS_RSX_REGISTER_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "UBSSTG"."MS_RSX_REGISTER_REPORT_PKG" AS
  FUNCTION get_inh_rec_rep(pc_PID        IN NUMBER
                          ,pc_FACT_MR_ID IN NUMBER
                          ,pc_CTRL_MR_ID IN NUMBER) RETURN inh_rep_tab
    PIPELINED IS
    lv_inh_rec_rep inh_rep_rec;
  BEGIN
    FOR outer_loop IN (select DISTINCT inh_rel_risk_id
                         from MS_RSX_RISK_ASSESSMENT_RPT
                        where instance_id =
                              (select max(instance_id)
                                 from MS_RSX_RISK_ASSESSMENT_RPT
                                where
                                PROCESS_INSTANCE_ID = pc_PID)
                          and multirow_region_id = pc_FACT_MR_ID)
    LOOP
      lv_inh_rec_rep := NULL;
      --Factor
      FOR innter_loop IN (select INH_FCT_SCORE
                                ,inh_factor_name
                                ,inh_lov_value
                            from MS_RSX_RISK_ASSESSMENT_RPT
                           where instance_id =
                                 (select max(instance_id)
                                    from MS_RSX_RISK_ASSESSMENT_RPT
                                   where
                                   PROCESS_INSTANCE_ID = pc_PID)
                             and multirow_region_id = pc_FACT_MR_ID
                             AND inh_rel_risk_id =
                                 outer_loop.inh_rel_risk_id
                             AND inh_factor_name <> 'RCSA'
                           order by inh_factor_name)
      LOOP
        lv_inh_rec_rep.RISK_ID := outer_loop.inh_rel_risk_id;
        --lv_inh_rec_rep.FACTOR_Name := innter_loop.inh_factor_name;
        IF innter_loop.inh_factor_name = 'Client'
        THEN
          lv_inh_rec_rep.FACTOR_Cli_SCORE  := innter_loop.inh_fct_score;
          lv_inh_rec_rep.FACTOR_Cli_Rating := innter_loop.inh_lov_value;
        ELSIF innter_loop.inh_factor_name = 'Financial'
        THEN
          lv_inh_rec_rep.FACTOR_Fin_SCORE  := innter_loop.inh_fct_score;
          lv_inh_rec_rep.FACTOR_Fin_Rating := innter_loop.inh_lov_value;
        ELSIF innter_loop.inh_factor_name = 'Market Impact'
        THEN
          lv_inh_rec_rep.FACTOR_Mar_SCORE  := innter_loop.inh_fct_score;
          lv_inh_rec_rep.FACTOR_Mar_Rating := innter_loop.inh_lov_value;
        ELSIF innter_loop.inh_factor_name = 'Regulatory'
        THEN
          lv_inh_rec_rep.FACTOR_Reg_SCORE  := innter_loop.inh_fct_score;
          lv_inh_rec_rep.FACTOR_Reg_Rating := innter_loop.inh_lov_value;
        ELSIF innter_loop.inh_factor_name = 'Reputational & Media'
        THEN
          lv_inh_rec_rep.FACTOR_Rep_SCORE  := innter_loop.inh_fct_score;
          lv_inh_rec_rep.FACTOR_Rep_Rating := innter_loop.inh_lov_value;
        END IF;
      END LOOP;
      --Control
      FOR innter_loop IN (select cft_factor_name
                                ,cft_lov_value
                                ,cft_scores
                                ,cft_factor_comments --- NEW w
                            from MS_RSX_RISK_ASSESSMENT_RPT
                           where instance_id =
                                 (select max(instance_id)
                                    from MS_RSX_RISK_ASSESSMENT_RPT
                                   where
                                   PROCESS_INSTANCE_ID = pc_PID)
                             and multirow_region_id = pc_CTRL_MR_ID
                             AND cft_rel_risk_id =
                                 outer_loop.inh_rel_risk_id
                           order by cft_factor_name)
      LOOP
        IF innter_loop.cft_factor_name = 'Culture & Training'
        THEN
          lv_inh_rec_rep.CONTRL_Col_SCORE  := innter_loop.cft_scores;
          lv_inh_rec_rep.CONTRL_Col_RATING := innter_loop.cft_lov_value;
        ELSIF innter_loop.cft_factor_name =
              'F2B Control Design Effectiveness'
        THEN
          lv_inh_rec_rep.CONTRL_Des_SCORE  := innter_loop.cft_scores;
          lv_inh_rec_rep.CONTRL_Des_RATING := innter_loop.cft_lov_value;
          lv_inh_rec_rep.CONTRL_Des_Eff_COMMENTS := innter_loop.cft_factor_comments;
        ELSIF innter_loop.cft_factor_name =
              'F2B Control Operating Effectiveness'
        THEN
          lv_inh_rec_rep.CONTRL_Opr_SCORE  := innter_loop.cft_scores;
          lv_inh_rec_rep.CONTRL_Opr_RATING := innter_loop.cft_lov_value;
          lv_inh_rec_rep.CONTRL_Des_COMMENTS := innter_loop.cft_factor_comments;
        ELSIF innter_loop.cft_factor_name = 'Issue Remediation Management'
        THEN
          lv_inh_rec_rep.CONTRL_Iss_SCORE  := innter_loop.cft_scores;
          lv_inh_rec_rep.CONTRL_Iss_RATING := innter_loop.cft_lov_value;
        ELSIF innter_loop.cft_factor_name =
              'Policies & Procedures & Processes & Governance'
        THEN
          lv_inh_rec_rep.CONTRL_Pol_SCORE  := innter_loop.cft_scores;
          lv_inh_rec_rep.CONTRL_Pol_RATING := innter_loop.cft_lov_value;
        END IF;
      END LOOP;
      PIPE ROW(lv_inh_rec_rep);
    END LOOP;
  END get_inh_rec_rep;
  --Assessment Report
  FUNCTION get_assmnt_rep(pc_SCN_ID IN VARCHAR2) RETURN assmnt_tab
    PIPELINED IS
    ln_MR_ID_ASMNT NUMBER;
    ln_MR_ID_INH   NUMBER;
    ln_MR_ID_CTL   NUMBER;
    lv_assmnt_rec  assmnt_rec;
    CURSOR cur_Rec(pn_pid          IN NUMBER
                  ,pn_assmnt_MR_ID IN NUMBER
                  ,pn_INH_MR_ID    IN NUMBER
                  ,pn_CTRL_MR_ID   IN NUMBER) IS
SELECT RSK.RISK_ID
    ,RISK_OWNERS
    ,RISK_CATEGORIES
    ,RSK_PROCESS_ID
    ,RSK_REL_ORG
    ,RSK_REL_PROC
    ,RISK_NAME
    ,RISK_LEVEL
    ,CAL_INH_RISK_SCORE
    ,CAL_INH_RISK_RATING
    ,IS_INH_OVERRIDEN
    ,CAL_RES_RISK_SCORE
    ,CAL_RES_RISK_RATING
    ,IS_RES_OVERRIDEN
    ,IS_CONTROL_OVERRIDEN
    ,CAL_CONTROL_RATING
    ,OVERALL_CONTROL_SCORE
    ,FINAL_OVERALL_CONTROL_SCORE
    ,FINAL_OVERALL_CONTROL_RATING
    ,FINAL_INHERENT_RATING
    ,PRIOR_INH_RATING
    ,FINAL_RESIDUAL_RATING
    ,PRIOR_RES_RATING
    ,RESIDUAL_SCORE
    ,RESIDUAL_TREND
    ,OBJECT_ID
    ,ASSMNT_ASSESSOR
    ,PROCESS_INSTANCE_ID
    ,ASSMNT_APPROVER
    ,FINAL_APPROVER
    ,REVIEWER
    ,ASSMNT_DUE_DATE
    ,ASSESSED_ON
    ,DELAYED_BY
    ,ASSESSED_BY
    ,APPROVED_BY
    ,ASSESSMENT_DETAILS
    ,PERSPECTIVE
    ,A_EXECUTIVE_SUMMARY
    ,IMMATERIAL_RISK
    ,PLAN_ID
    ,FACTOR_REP_SCORE
    ,FACTOR_REP_RATING
    ,FACTOR_CLI_SCORE
    ,FACTOR_CLI_RATING
    ,FACTOR_FIN_SCORE
    ,FACTOR_FIN_RATING
    ,FACTOR_MAR_SCORE
    ,FACTOR_MAR_RATING
    ,FACTOR_REG_SCORE
    ,FACTOR_REG_RATING
    ,CONTRL_POL_SCORE
    ,CONTRL_POL_RATING
    ,CONTRL_ISS_SCORE
    ,CONTRL_ISS_RATING
    ,CONTRL_DES_SCORE
    ,CONTRL_DES_RATING
    ,CONTRL_COL_SCORE
    ,CONTRL_COL_RATING
    ,CONTRL_OPR_SCORE
    ,CONTRL_OPR_RATING
    ,NULL                         AS SCN_NAME
    ,NULL                         AS PLAN_NAME
    ,NULL                         AS PUR_SCOPE
    ,PROGRESS_STATUS
    ,NULL                         AS DUMMY1
    ,NULL                         AS DUMMY2
    ,NULL                         AS DUMMY3
    ,RISK_ASSESSMENT_TYPE            --AS DUMMY4
    ,RELATED_RISKS                   --AS DUMMY5
    ,A_TAXONOMY_ASSESSMENT_HAS_THER  --AS DUMMY6
    ,Residual_Trend_Filt          AS DUMMY7
    ,(SELECT ms_concat(SI_MDOS_SV.get_mdos_display_values(abh1.ASSESS_BH,',','|','SYS','1009')) AS own_org FROM MS_RSK_SCHEDULE_RISK_A_aBH abh1 WHERE plan_id=abh1.Object_id)   AS DUMMY8
    ,(SELECT ms_concat (business_name) FROM ms_rsx_business_owner_list lst, a_ms_rsx_schedule_risk_x03 o WHERE lst.gpn = o.a_business_owner_x10 AND o.object_id=plan_id)     AS DUMMY9                      
    ,(SELECT ms_concat(SI_MDOS_SV.get_mdos_display_values(obh1.OWNER_BH,',','|','SYS','1009')) AS own_org FROM MS_RSK_SCHEDULE_RISK_A_oBH obh1 WHERE plan_id=obh1.Object_id)    AS DUMMY10
    ,A_RISK_DRIVER                                AS DUMMY11
    ,A_OR_LEVEL_3_TAXONOMY                        AS DUMMY12
    ,A_REMEDIATION_ACTIONS                        AS DUMMY13
    ,A_DEFINITION_REMEDIATION_ACT                 AS DUMMY14
    ,A_IS_RESIDUAL_RISK_WITHIN                    AS DUMMY15
    ,LEVEL2_APPROVER                                AS LEVEL2_APPROVER
    ,A_OVERALL_CTL_COM              AS A_OVERALL_CTL_COM     --NEW w
    ,A_OVERALL_RES_RISK_COM   AS A_OVERALL_RES_RISK_COM  --NEW w
    , CONTRL_Des_COMMENTS  AS CONTRL_Des_COMMENTS  --NEW w
    ,CONTRL_Des_Eff_COMMENTS  AS CONTRL_Des_Eff_COMMENTS  --NEW
    ,A_OVERALL_INH_RISK_COM AS A_OVERALL_INH_RISK_COM  --NEW
    
from (select 
             b.RISK_ASSESSMENT_TYPE            --AS DUMMY4
             ,b.RELATED_RISKS                   --AS DUMMY5
             ,MS_APPS_UTILITIES.GET_DISPLAY_VALUE( MS_GRC_UTILITIES.ACTIVE_ENT_ID, 'MS_RSX_YES_NO', B.A_TAXONOMY_ASSESSMENT_HAS_THER, 1, 1009)
                      AS A_TAXONOMY_ASSESSMENT_HAS_THER                ---dummy6
             ,A_OVERALL_CTL_COM
            , A_OVERALL_RES_RISK_COM
            ,A_OVERALL_INH_RISK_COM
            ,b.risk_id
            ,b.risk_owners                
            ,(select MS_CONCAT(ms_apps_utilities.get_display_value(100000, 'MS GRC Risk Category' ,category_risk))
                from ms_grc_risk_cat 
               where object_id = b.risk_id) as risk_categories 
            ,b.rsk_process_id
            ,b.rsk_rel_org
            ,b.rsk_rel_proc
            ,Case
               When B.Rsk_Flag in (1, 2) Then
                (select object_name
                   from ms_grc_risk
                  where object_id = b.risk_id)
               Else
                B.Ad_Hoc_Risk_Title
             end As Risk_Name
            ,'Level-' || nvl((select object_level
                               from ms_grc_risk
                              where object_id = b.risk_id)
                            ,b.rsk_level) as RISK_LEVEL
            ,REGEXP_SUBSTR(nvl2(b.rsk_override_score
                               ,b.RSK_INH_CALC_SCORE
                               ,rsk_assessed_rating)
                          ,'\d+') as cal_inh_risk_score
            ,MS_RSK_GET_SPLIT_VALUE(nvl2(b.rsk_override_score
                                        ,b.RSK_INH_CALC_SCORE
                                        ,rsk_assessed_rating)
                                   ,1
                                   ,'[') as cal_inh_risk_rating
            ,nvl2(b.rsk_override_score, 'Yes', 'No') as is_inh_overriden
            ,REGEXP_SUBSTR(nvl2(rsk_override_score_res
                               ,b.RSK_RES_CALC_SCORE
                               ,rsk_assessed_rating_res)
                          ,'\d+') as cal_res_risk_score
            ,MS_RSK_GET_SPLIT_VALUE(nvl2(rsk_override_score_res
                                        ,b.RSK_RES_CALC_SCORE
                                        ,rsk_assessed_rating_res)
                                   ,1
                                   ,'[') as cal_res_risk_rating
            ,nvl2(b.rsk_override_score_res, 'Yes', 'No') as is_res_overriden
            ,nvl2(b.override_control_score, 'Yes', 'No') as is_control_overriden
            ,b.control_effectiv as cal_CONTROL_RATING
            ,b.OVERALL_CONTROL_SCR_RSK as overall_control_score
            ,NVL(override_control_score, b.OVERALL_CONTROL_SCR_RSK) as final_overall_control_score
            ,NVL(override_control_rating, b.control_effectiv) as final_overall_control_rating
            ,NVL(TRIM(SUBSTR(RSK_ASSESSED_RATING
                            ,0
                            ,INSTR(RSK_ASSESSED_RATING, '[', 1) - 1))
                ,TRIM(RSK_ASSESSED_RATING)) AS FINAL_INHERENT_RATING
            ,NVL(TRIM(SUBSTR(RSK_PREVIOUS_RATING
                            ,0
                            ,INSTR(RSK_PREVIOUS_RATING, '[', 1) - 1))
                ,TRIM(RSK_PREVIOUS_RATING)) as PRIOR_INH_RATING
            ,NVL(TRIM(SUBSTR(RSK_ASSESSED_RATING_RES
                            ,0
                            ,INSTR(RSK_ASSESSED_RATING_RES, '[', 1) - 1))
                ,TRIM(RSK_ASSESSED_RATING_RES)) AS FINAL_RESIDUAL_RATING
            ,NVL(TRIM(SUBSTR(RSK_PREVIOUS_RATING_RES
                            ,0
                            ,INSTR(RSK_PREVIOUS_RATING_RES, '[', 1) - 1))
                ,TRIM(RSK_PREVIOUS_RATING_RES)) AS PRIOR_RES_RATING
            ,B.RSK_ASSESS_RES_HIDN AS Residual_Score
            ,CASE
               when b.RSK_PREVIOUS_SCORE_RES is null OR
                    B.RSK_ASSESS_RES_HIDN is null then
                Null
               when b.RSK_PREVIOUS_SCORE_RES is not null and
                    B.RSK_ASSESS_RES_HIDN is not null THEN
                Case
                  When B.RSK_ASSESS_RES_HIDN - B.RSK_PREVIOUS_SCORE_RES > 0 THEN
                   ms_rsk_rpt_utils.build_image_url('Upward')
                  when B.RSK_ASSESS_RES_HIDN - B.RSK_PREVIOUS_SCORE_RES = 0 THEN
                   ms_rsk_rpt_utils.build_image_url('No Change')
                  when B.RSK_ASSESS_RES_HIDN - B.RSK_PREVIOUS_SCORE_RES < 0 THEN
                   ms_rsk_rpt_utils.build_image_url('Downward')
                end
             END AS Residual_Trend
             ,CASE
               when b.RSK_PREVIOUS_SCORE_RES is null OR
                    B.RSK_ASSESS_RES_HIDN is null then
                Null
               when b.RSK_PREVIOUS_SCORE_RES is not null and
                    B.RSK_ASSESS_RES_HIDN is not null THEN
                Case
                  When B.RSK_ASSESS_RES_HIDN - B.RSK_PREVIOUS_SCORE_RES > 0 THEN
                   'Upward'
                  when B.RSK_ASSESS_RES_HIDN - B.RSK_PREVIOUS_SCORE_RES = 0 THEN
                   'No Change'
                  when B.RSK_ASSESS_RES_HIDN - B.RSK_PREVIOUS_SCORE_RES < 0 THEN
                   'Downward'
                END
             END AS Residual_Trend_Filt
             ,ms_apps_utilities.get_display_values( MS_GRC_UTILITIES.active_ent_id, 'MS_RSX_RISK_DRIVERS', b.A_RISK_DRIVER, 1, 1009) as A_RISK_DRIVER
             ,b.A_OR_LEVEL_3_TAXONOMY
             ,ms_apps_utilities.get_display_values( MS_GRC_UTILITIES.active_ent_id, 'MS_RSX_REMEDIATION_ACTION', b.A_REMEDIATION_ACTIONS, 1, 1009) as A_REMEDIATION_ACTIONS
             ,b.A_DEFINITION_REMEDIATION_ACT
             ,MS_APPS_UTILITIES.GET_DISPLAY_VALUE( MS_GRC_UTILITIES.ACTIVE_ENT_ID, 'MS_RSX_YES_NO', B.A_IS_RESIDUAL_RISK_WITHIN, 1, 1009) AS A_IS_RESIDUAL_RISK_WITHIN
             ,A_RISK_APPETITE_STATEMENT
        FROM MS_RSX_RISK_ASSESSMENT_RPT B
       WHERE b.instance_id =
             (SELECT MAX(instance_id)
                FROM MS_RSX_RISK_ASSESSMENT_RPT
               WHERE PROCESS_INSTANCE_ID = pn_pid)
        -- and b.multirow_region_id = pn_assmnt_mr_id          -- COMMENTED NEW
         AND B.RISK_ID IS NOT NULL                                              -- ADDED NEW
         ) rsk
    ,(select b.a_status_dummy as level2_approver,                -- ADDED NEW
            b.object_id
            ,b.assessor as ASSMNT_ASSESSOR
            ,b.process_instance_id
            ,b.REVIEWER as ASSMNT_APPROVER                      -- Level1 Approver
            ,b.sch_assmnt_final_approver as FINAL_APPROVER
            ,b.Action_Reviewer as REVIEWER
            --,b.ASSESSMENT_DATE AS Assmnt_Due_Date
            --,b.ASSESSED_ON AS Assessed_On
            ,to_char(b.ASSESSMENT_DATE,'DD-MON-RRRR') AS Assmnt_Due_Date
            ,to_char(b.ASSESSED_ON,'DD-MON-RRRR') AS Assessed_On
            ,ROUND(TRUNC(b.ASSESSED_ON) - TRUNC(b.ASSESSMENT_DATE)) AS DELAYED_BY
            ,(select user_full_name
                from Ms_Grc_User_Full_Name_V
               where user_name = b.ASSESSED_BY) AS Assessed_By
            ,(select user_full_name
                from Ms_Grc_User_Full_Name_V
               where user_name = b.REVIEWER) AS Approved_By
            ,b.object_id            AS Assessment_Details
            ,b.scenario_name        as PERSPECTIVE
            ,b.a_executive_summary
            ,b.A_ASSESSMENT_ON_RISK as immaterial_risk
            ,b.schedule_risk_id     as plan_id
            ,ms_apps_utilities.get_display_value ( MS_GRC_UTILITIES.active_ent_id, 'MS_RSK_STATUS', b.progress_status)  as progress_status
        from MS_RSX_RISK_ASSESSMENT_RPT B
       WHERE b.instance_id =
             (SELECT MAX(instance_id)
                FROM MS_RSX_RISK_ASSESSMENT_RPT
               WHERE PROCESS_INSTANCE_ID = pn_pid)
         and b.instance_rec_num = 1) asmt
    ,(select RISK_ID
            ,FACTOR_Rep_SCORE
            ,FACTOR_Rep_Rating
            ,FACTOR_Cli_SCORE
            ,FACTOR_Cli_Rating
            ,FACTOR_Fin_SCORE
            ,FACTOR_Fin_Rating
            ,FACTOR_Mar_SCORE
            ,FACTOR_Mar_Rating
            ,FACTOR_Reg_SCORE
            ,FACTOR_Reg_Rating
            ,CONTRL_Pol_SCORE
            ,CONTRL_Pol_Rating
            ,CONTRL_Iss_SCORE
            ,CONTRL_Iss_Rating
            ,CONTRL_Des_SCORE
            ,CONTRL_Des_Rating
            ,CONTRL_Col_SCORE
            ,CONTRL_Col_Rating
            ,CONTRL_Opr_SCORE
            ,CONTRL_Opr_Rating
            ,CONTRL_Des_COMMENTS  -- NEW
            ,CONTRL_Des_Eff_COMMENTS -- New
        from table(MS_RSX_REGISTER_REPORT_PKG.get_inh_rec_rep(pn_pid
                                                          ,pn_INH_MR_ID
                                                          ,pn_CTRL_MR_ID))) rat
WHERE rat.risk_id = rsk.risk_id;

    lv_Plan_Perspective VARCHAR2(4000);
  BEGIN
    BEGIN
      SELECT Object_Name
        INTO lv_Plan_Perspective
        FROM ms_rsk_perspective
       where scenario_id = pc_SCN_ID;
    EXCEPTION
      WHEN OTHERS THEN
        lv_Plan_Perspective := NULL;
    END;
  
    SELECT multirow_id
      INTO ln_MR_ID_ASMNT
      FROM si_metric_columns
     WHERE metric_id =
           (SELECT metric_id
              FROM si_metrics_t
             WHERE metric_name = 'MS_RSK_RISK_ASSESSMENT')
       AND result_column_name IN ('KEY_RISK');
  
    SELECT multirow_id
      INTO ln_MR_ID_INH
      FROM si_metric_columns
     WHERE metric_id =
           (SELECT metric_id
              FROM si_metrics_t
             WHERE metric_name = 'MS_RSK_RISK_ASSESSMENT')
       AND result_column_name IN ('INH_PK');
  
    SELECT multirow_id
      INTO ln_MR_ID_CTL
      FROM si_metric_columns
     WHERE metric_id =
           (SELECT metric_id
              FROM si_metrics_t
             WHERE metric_name = 'MS_RSK_RISK_ASSESSMENT')
       AND result_column_name IN ('CFT_PK');
  
    FOR out_loop IN (select object_id
                           ,max(process_instance_id) AS process_instance_id
                       from MS_RSX_RISK_ASSESSMENT_RPT
                      where scenario_name = pc_SCN_ID
                     --and process_instance_id = 14080
                      group by object_id)
    LOOP
      OPEN cur_Rec(out_loop.process_instance_id
                  ,ln_MR_ID_ASMNT
                  ,ln_MR_ID_INH
                  ,ln_MR_ID_CTL);
      LOOP
        FETCH cur_Rec
          INTO lv_assmnt_rec;
        EXIT WHEN cur_Rec%NOTFOUND;
        lv_assmnt_rec.SCN_NAME :=lv_Plan_Perspective;
        BEGIN
          SELECT OBJECT_NAME
                ,A_PURPOSE_SCOPE_X8              
            INTO lv_assmnt_rec.PLAN_NAME
                ,lv_assmnt_rec.PUR_SCOPE
            FROM MS_RSK_SCHEDULE_RISK_A x
                ,A_MS_RSX_SCHEDULE_RISK B
           WHERE x.Object_Id = lv_assmnt_rec.PLAN_ID
             AND x.Object_Id = B.Object_Id;
        EXCEPTION 
          WHEN OTHERS THEN
            lv_assmnt_rec.PLAN_NAME :='';
            lv_assmnt_rec.PUR_SCOPE :='';
        END;
        PIPE ROW(lv_assmnt_rec);
      END LOOP;
      CLOSE cur_Rec;
    END LOOP;
  END get_assmnt_rep;
END MS_RSX_REGISTER_REPORT_PKG;

/
