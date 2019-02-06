CREATE OR REPLACE PACKAGE MS_GRC_CONTROL_API_PKG
AS
  TYPE control_rec IS RECORD(
     object_id              VARCHAR2(4000)
    ,object_name            VARCHAR2(4000)
    ,key_control            VARCHAR2(10)
    ,object_level           VARCHAR2(10)
    ,object_parent          VARCHAR2(4000)
    ,description            VARCHAR2(4000)
    ,control_purpose        VARCHAR2(4000)
    ,control_type           VARCHAR2(4000)
    ,control_nature         VARCHAR2(4000)
    ,control_priority       VARCHAR2(4000)
    ,control_source         VARCHAR2(4000)
    ,control_frequency      VARCHAR2(4000)
    ,valid_from             VARCHAR2(4000)
    ,valid_until            VARCHAR2(4000)
    ,own_org                VARCHAR2(4000)
    ,owners                 VARCHAR2(4000)
    ,L1_appv                VARCHAR2(4000)
    ,L2_appv                VARCHAR2(4000)
    ,restrict_access_to     VARCHAR2(4000)
    ,status                 VARCHAR2(4000)
    ,created_on             VARCHAR2(4000)
    ,createdd_by            VARCHAR2(4000)
    ,modified_on            VARCHAR2(4000)
    ,modified_by            VARCHAR2(4000)
    ,attachments            VARCHAR2(4000)
   );
   
   TYPE control_tab is table of control_rec;
   
   FUNCTION get_control_fun RETURN control_tab PIPELINED;

END MS_GRC_CONTROL_API_PKG;



--====================Package body=====================

CREATE OR REPLACE PACKAGE BODY MS_GRC_CONTROL_API_PKG
IS
  FUNCTION get_control_fun RETURN control_tab PIPELINED 
  IS
    lv_control_rec control_rec;
    
    
    CURSOR control_cur 
    IS
      SELECT 
         a.OBJECT_ID
        ,a.OBJECT_NAME
        ,b.KEY_CONTROL
        ,b.OBJECT_LEVEL
        ,(SELECT object_name from MS_GRC_CONTROL_SUMMARY a_t where a_t.object_id=a.parent) AS OBJECT_PARENT
        ,a.DESCRIPTION
        ,b.CONTROL_PURPOSE as PURPOSE
        ,b.CONTROL_TYPE as TYPES
        ,b.CONTROL_NATURE as NATURE
        ,b.CONTROL_PRIORITY as PRIORITY
        ,b.CONTROL_SOURCE as SOURCE
        ,b.CONTROL_FREQUENCY as EXECUTION_FREQUENCY
        ,TO_CHAR(a.valid_from,'MM/DD/YYYY') as VALID_FROM
        ,TO_CHAR(a.valid_until,'MM/DD/YYYY') as VALID_UNTIL
        ,a.OWNER_ORG_NAMES
        ,a.OWNER_NAME as OWNERS
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.LEVEL_1_APPROVER)) as LEVEL1_APPROVER
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.LEVEL_2_APPROVER)) as LEVEL2_APPROVER
        ,DECODE(restrict_access_to,'N','No Restriction','O','Owner Organizations','A','Owner Organizations and Applies to Organizations') AS restrict_access_to
        ,DECODE(a.OBJ_STATUS_SV, 'ACT', 'Active', 'INACT', 'Inactive', 'Expired') AS STATUS
        ,TO_CHAR(a.created_date,'MM/DD/YYYY') AS CREATED_ON
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.CREATED_BY)) AS CREATEDD_BY
        ,TO_CHAR(updated_date,'MM/DD/YYYY') AS MODIFIED_ON
        ,(SELECT FIRST_NAME ||' '||LAST_NAME ||' '||USER_NAME FROM si_users_t WHERE user_name=TO_CHAR(a.UPDATED_BY)) AS MODIFIED_BY
        ,ATTACHMENTS      

      FROM MS_GRC_CONTROL_SUMMARY a, MS_GRC_CONTROL_MLS_SUMMARY b
        where a.object_id = b.object_id;
      
    BEGIN
      OPEN control_cur;
      
      LOOP
        FETCH control_cur INTO lv_control_rec;
        EXIT WHEN control_cur%NOTFOUND;
        PIPE ROW(lv_control_rec);
      END LOOP;
      CLOSE control_cur;
    EXCEPTION
      WHEN OTHERS THEN
        CLOSE control_cur;
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END get_control_fun;
END MS_GRC_CONTROL_API_PKG;
  
--============
select *
  from table(MS_GRC_RISK_API_PKG.get_risk_fun);


----==================infolet_query

SELECT
     object_id 
    ,object_name
    ,key_control
    ,object_level
    ,object_parent
    ,description
    ,control_purpose
    ,control_type
    ,control_nature
    ,control_priority
    ,control_source
    ,control_frequency
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
  FROM table(MS_GRC_CONTROL_API_PKG.get_control_fun)
  WHERE
    (:p_object_id IS NULL OR ','||:p_object_id||',' LIKE '%,'||object_id||',%')
    AND (:p_object_name IS NULL OR ','||:p_object_name||',' LIKE '%,'||object_name||',%')
    AND NVL(object_level,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_level,object_level),'2222'),',')))
    AND NVL(status,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_status,status),'2222'),',')))
    AND NVL(key_control,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_key_control,key_control),'2222'),',')))
    AND NVL(control_purpose,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_purpose,control_purpose),'2222'),',')))
    AND NVL(control_source,'2222') IN (SELECT COLUMN_VALUE FROM  TABLE (ms_apps_utilities.SPLIT_STRING(NVL(NVL(:p_source,control_source),'2222'),',')));

