CREATE OR REPLACE PACKAGE MS_GRC_RISK_API_PKG
AS
  TYPE risk_rec IS RECORD(
     object_id              VARCHAR2(4000)
    ,object_name            VARCHAR2(4000)
    ,key_risk               VARCHAR2(10)
    ,object_level           VARCHAR2(10)
    ,object_parent          VARCHAR2(4000)
    ,description            VARCHAR2(4000)
    ,risk_categories        VARCHAR2(4000)
    ,risk_type              VARCHAR2(4000)
    ,aov                    VARCHAR2(4000)
    ,valid_from             VARCHAR2(4000)
    ,valid_until            VARCHAR2(4000)
    ,own_org                VARCHAR2(4000)
    ,owners                 VARCHAR2(4000)
    ,L1_appv                VARCHAR2(4000)
    ,L2_appv                VARCHAR2(4000)
    ,restrict_access_to      VARCHAR2(4000)
    ,status                 VARCHAR2(4000)
    ,created_on             VARCHAR2(4000)
    ,createdd_by            VARCHAR2(4000)
    ,modified_on            VARCHAR2(4000)
    ,modified_by            VARCHAR2(4000)
    ,attachments            VARCHAR2(4000)
   );
   
   TYPE risk_tab is table of risk_rec;

   FUNCTION get_risk_fun RETURN risk_tab PIPELINED;

END MS_GRC_RISK_API_PKG;



--====================Package body=====================

CREATE OR REPLACE PACKAGE BODY MS_GRC_RISK_API_PKG
IS

  FUNCTION get_risk_fun RETURN risk_tab PIPELINED 
  IS
    lv_risk_rec risk_rec;
    
    
    CURSOR risk_cur 
    IS
      SELECT 
         a.OBJECT_ID
        ,OBJECT_NAME
        ,DECODE(key_risk_sv,'no','No','yes','Yes') AS KEY_RISK
        ,'Level '||obj_level_sv
        ,OBJECT_PARENT
        ,DESCRIPTION
        ,b.CAT_NAME_AGG as risk_categories
        ,b.TYPE_RISK as risk_type
        ,b.AREAS_OF_IMPACT as IMPACT_SV  --doubt MS GRC Area of Impact
        ,TO_CHAR(valid_from,'MM/DD/YYYY') as valid_from
        ,TO_CHAR(valid_until,'MM/DD/YYYY') as valid_until
        ,OWNER_ORG_NAMES
        ,a.owner_name as OWNERS
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.LEVEL_1_APPROVER)) as LEVEL1_APPROVER
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.LEVEL_2_APPROVER)) as LEVEL2_APPROVER
        ,DECODE(restrict_access_to,'N','No Restriction','O','Owner Organizations','A','Owner Organizations and Applies to Organizations') AS restrict_access_to
        ,DECODE(OBJ_STATUS_SV, 'ACT', 'Active', 'INACT', 'Inactive', 'Expired') AS STATUS
        ,TO_CHAR(created_date,'MM/DD/YYYY') AS CREATED_ON
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.CREATED_BY)) AS CREATEDD_BY
        ,TO_CHAR(updated_date,'MM/DD/YYYY') AS MODIFIED_ON
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.UPDATED_BY)) AS MODIFIED_BY
        ,(SELECT get_attachment_values(a.attachments) from dual) as ATTACHMENTS     

      FROM MS_GRC_RISK_OBJ_SUMMARY a, MS_GRC_RISK_OBJ_MLS_SUMMARY b
        where a.object_id = b.object_id;
      
    BEGIN
      OPEN risk_cur;
      
      LOOP
        FETCH risk_cur INTO lv_risk_rec;
        EXIT WHEN risk_cur%NOTFOUND;
        PIPE ROW(lv_risk_rec);
      END LOOP;
      CLOSE risk_cur;
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE risk_cur;
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END get_risk_fun;
END MS_GRC_RISK_API_PKG;
  
--============
select *
  from table(MS_GRC_RISK_API_PKG.get_risk_fun);


----==================infolet_query

SELECT
     object_id
    ,object_name
    ,key_risk 
    ,object_level
    ,object_parent
    ,description
    ,risk_categories
    ,risk_type
    ,aov
    ,valid_from
    ,valid_until
    ,own_org
    ,owners
    ,L1_appv
    ,L2_appv
    ,restrict_access_to
    ,status
    ,created_on
    ,createdd_by
    ,modified_on
    ,modified_by
    ,attachments
  FROM table(MS_GRC_RISK_API_PKG.get_risk_fun)
  WHERE
    (:p_object_id IS NULL OR ','||:p_object_id||',' LIKE '%,'||object_id||',%')
    AND (:p_object_name IS NULL OR ','||:p_object_name||',' LIKE '%,'||object_name||',%')
    AND NVL(object_level,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_level,object_level),'2222'),',')))
    AND NVL(status,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_status,status),'2222'),',')))
    AND NVL(key_risk,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_key_risk,key_risk),'2222'),',')));

