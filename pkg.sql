--------------------------------------------------------
--  File created - Thursday-October-04-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package MS_RSX_REGISTER_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "UBSSTG"."MS_RSX_REGISTER_REPORT_PKG" AS
  TYPE inh_rep_rec IS RECORD(
     RISK_ID VARCHAR2(4000)
    --,FACTOR_Name       VARCHAR2(4000)
    ,FACTOR_Rep_SCORE  VARCHAR2(4000)
    ,FACTOR_Rep_Rating VARCHAR2(4000)
    ,FACTOR_Cli_SCORE  VARCHAR2(4000)
    ,FACTOR_Cli_Rating VARCHAR2(4000)
    ,FACTOR_Fin_SCORE  VARCHAR2(4000)
    ,FACTOR_Fin_Rating VARCHAR2(4000)
    ,FACTOR_Mar_SCORE  VARCHAR2(4000)
    ,FACTOR_Mar_Rating VARCHAR2(4000)
    ,FACTOR_Reg_SCORE  VARCHAR2(4000)
    ,FACTOR_Reg_Rating VARCHAR2(4000)
    --
    ,CONTRL_Pol_SCORE  VARCHAR2(4000)
    ,CONTRL_Pol_Rating VARCHAR2(4000)
    ,CONTRL_Iss_SCORE  VARCHAR2(4000)
    ,CONTRL_Iss_Rating VARCHAR2(4000)
    ,CONTRL_Des_SCORE  VARCHAR2(4000)
    ,CONTRL_Des_Rating VARCHAR2(4000)
    ,CONTRL_Col_SCORE  VARCHAR2(4000)
    ,CONTRL_Col_Rating VARCHAR2(4000)
    ,CONTRL_Opr_SCORE  VARCHAR2(4000)
    ,CONTRL_Opr_Rating VARCHAR2(4000)
    
    ,CONTRL_Des_COMMENTS  VARCHAR2(4000)  --NEW w
    ,CONTRL_Des_Eff_COMMENTS VARCHAR2(4000)  --NEW
    );
  TYPE inh_rep_tab IS TABLE OF inh_rep_rec;
  FUNCTION get_inh_rec_rep(pc_PID        IN NUMBER
                          ,pc_FACT_MR_ID IN NUMBER
                          ,pc_CTRL_MR_ID IN NUMBER) RETURN inh_rep_tab
    PIPELINED;

  TYPE assmnt_rec IS RECORD(
     RISK_ID                      VARCHAR2(4000)
    ,RISK_OWNERS                  VARCHAR2(4000)
    ,RISK_CATEGORIES              VARCHAR2(4000)
    ,RSK_PROCESS_ID               VARCHAR2(4000)
    ,RSK_REL_ORG                  VARCHAR2(4000)
    ,RSK_REL_PROC                 VARCHAR2(4000)
    ,RISK_NAME                    VARCHAR2(4000)
    ,RISK_LEVEL                   VARCHAR2(4000)
    ,CAL_INH_RISK_SCORE           VARCHAR2(4000)
    ,CAL_INH_RISK_RATING          VARCHAR2(4000)
    ,IS_INH_OVERRIDEN             VARCHAR2(4000)
    ,CAL_RES_RISK_SCORE           VARCHAR2(4000)
    ,CAL_RES_RISK_RATING          VARCHAR2(4000)
    ,IS_RES_OVERRIDEN             VARCHAR2(4000)
    ,IS_CONTROL_OVERRIDEN         VARCHAR2(4000)
    ,CAL_CONTROL_RATING           VARCHAR2(4000)
    ,OVERALL_CONTROL_SCORE        VARCHAR2(4000)
    ,FINAL_OVERALL_CONTROL_SCORE  VARCHAR2(4000)
    ,FINAL_OVERALL_CONTROL_RATING VARCHAR2(4000)
    ,FINAL_INHERENT_RATING        VARCHAR2(4000)
    ,PRIOR_INH_RATING             VARCHAR2(4000)
    ,FINAL_RESIDUAL_RATING        VARCHAR2(4000)
    ,PRIOR_RES_RATING             VARCHAR2(4000)
    ,RESIDUAL_SCORE               VARCHAR2(4000)
    ,RESIDUAL_TREND               VARCHAR2(4000)
    ,OBJECT_ID                    VARCHAR2(4000)
    ,ASSMNT_ASSESSOR              VARCHAR2(4000)
    ,PROCESS_INSTANCE_ID          VARCHAR2(4000)
    ,ASSMNT_APPROVER              VARCHAR2(4000)
    ,FINAL_APPROVER               VARCHAR2(4000)
    ,REVIEWER                     VARCHAR2(4000)
    ,ASSMNT_DUE_DATE              VARCHAR2(4000)
    ,ASSESSED_ON                  VARCHAR2(4000)
    ,DELAYED_BY                   VARCHAR2(4000)
    ,ASSESSED_BY                  VARCHAR2(4000)
    ,APPROVED_BY                  VARCHAR2(4000)
    ,ASSESSMENT_DETAILS           VARCHAR2(4000)
    ,PERSPECTIVE                  VARCHAR2(4000)
    ,A_EXECUTIVE_SUMMARY          VARCHAR2(4000)
    ,IMMATERIAL_RISK              VARCHAR2(4000)
    ,PLAN_ID                      VARCHAR2(4000)
    ,FACTOR_REP_SCORE             VARCHAR2(4000)
    ,FACTOR_REP_RATING            VARCHAR2(4000)
    ,FACTOR_CLI_SCORE             VARCHAR2(4000)
    ,FACTOR_CLI_RATING            VARCHAR2(4000)
    ,FACTOR_FIN_SCORE             VARCHAR2(4000)
    ,FACTOR_FIN_RATING            VARCHAR2(4000)
    ,FACTOR_MAR_SCORE             VARCHAR2(4000)
    ,FACTOR_MAR_RATING            VARCHAR2(4000)
    ,FACTOR_REG_SCORE             VARCHAR2(4000)
    ,FACTOR_REG_RATING            VARCHAR2(4000)
    ,CONTRL_POL_SCORE             VARCHAR2(4000)
    ,CONTRL_POL_RATING            VARCHAR2(4000)
    ,CONTRL_ISS_SCORE             VARCHAR2(4000)
    ,CONTRL_ISS_RATING            VARCHAR2(4000)
    ,CONTRL_DES_SCORE             VARCHAR2(4000)
    ,CONTRL_DES_RATING            VARCHAR2(4000)
    ,CONTRL_COL_SCORE             VARCHAR2(4000)
    ,CONTRL_COL_RATING            VARCHAR2(4000)
    ,CONTRL_OPR_SCORE             VARCHAR2(4000)
    ,CONTRL_OPR_RATING            VARCHAR2(4000)
    ,SCN_NAME                     VARCHAR2(4000)
    ,PLAN_NAME                    VARCHAR2(4000)
    ,PUR_SCOPE                    VARCHAR2(4000)
    ,PROGRESS_STATUS              VARCHAR2(4000)
    ,DUMMY1                       VARCHAR2(4000)
    ,DUMMY2                       VARCHAR2(4000)
    ,DUMMY3                       VARCHAR2(4000)
    ,RISK_ASSESSMENT_TYPE         VARCHAR2(4000)   --added
    ,RELATED_RISKS                VARCHAR2(4000)   --added
    ,A_TAXONOMY_ASSESSMENT_HAS_THER  VARCHAR2(4000)  --added
    ,DUMMY7                       VARCHAR2(4000)
    ,DUMMY8                       VARCHAR2(4000)
    ,DUMMY9                       VARCHAR2(4000)
    ,DUMMY10                      VARCHAR2(4000)
    ,DUMMY11                      VARCHAR2(4000)
    ,DUMMY12                      VARCHAR2(4000)
    ,DUMMY13                      VARCHAR2(4000)
    ,DUMMY14                      VARCHAR2(4000)
    ,DUMMY15                      VARCHAR2(4000)
    ,LEVEL2_APPROVER          VARCHAR2(4000)
    ,A_OVERALL_CTL_COM               VARCHAR2(4000)
    ,A_OVERALL_RES_RISK_COM      VARCHAR2(4000)
        ,CONTRL_Des_Eff_COMMENTS  VARCHAR2(4000)  --NEW w
    ,CONTRL_Des_COMMENTS  VARCHAR2(4000)  --NEW w
    ,A_OVERALL_INH_RISK_COM VARCHAR2(4000)  --NEW 
    );
  TYPE assmnt_tab IS TABLE OF assmnt_rec;

  FUNCTION get_assmnt_rep(pc_SCN_ID IN VARCHAR2) RETURN assmnt_tab
    PIPELINED;

END MS_RSX_REGISTER_REPORT_PKG;

/
