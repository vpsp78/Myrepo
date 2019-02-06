--editing again
DECLARE
  TYPE EMP_REC IS RECORD(
    EMPNO  EMP1.EMPNO%TYPE,
    ENAME  EMP1.ENAME%TYPE,
    DEPTNO EMP1.DEPTNO%TYPE,
    SAL    EMP1.SAL%TYPE);
  TYPE EMP_REC_T IS TABLE OF EMP_REC;
  V_EMP_REC EMP_REC_T := EMP_REC_T();

  TYPE EMP_REC_UPD IS RECORD(
    ENAME EMP1.ENAME%TYPE,
    SAL   EMP1.SAL%TYPE);
  TYPE EMP_REC_UPD_T IS TABLE OF EMP_REC_UPD;
  V_EMP_REC_UPD EMP_REC_UPD_T := EMP_REC_UPD_T();

  V_BULK_ERR EXCEPTION;
  PRAGMA EXCEPTION_INIT(V_BULK_ERR, -24381);

BEGIN
  SELECT EMPNO, ENAME, DEPTNO, SAL BULK COLLECT INTO V_EMP_REC FROM EMP1;

  FORALL i IN V_EMP_REC.FIRST .. V_EMP_REC.LAST SAVE EXCEPTIONS
    UPDATE EMP1
       SET SAL = V_EMP_REC(i).SAL + 1000
     WHERE EMPNO = V_EMP_REC(i).EMPNO
    RETURNING ENAME, SAL BULK COLLECT INTO V_EMP_REC_UPD;

  FOR i IN V_EMP_REC_UPD.FIRST .. V_EMP_REC_UPD.LAST LOOP
    DBMS_OUTPUT.PUT_LINE('SALARY OF ' || V_EMP_REC_UPD(i).ENAME || ' = ' || V_EMP_REC_UPD(i).SAL);
  END LOOP;
EXCEPTION
  WHEN V_BULK_ERR THEN
    FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(SQL%BULK_EXCEPTIONS(i)
                           .ERROR_INDEX || '----' || SQL%BULK_EXCEPTIONS(i)
                           .ERROR_CODE || '----' || SQLERRM);
    END LOOP;
END;
















/*


WITH T1 AS 
(SELECT SUBMISSION_DATE, S.HACKER_ID, COUNT (*)AS "MY_COUNT" FROM SUBMISSIONS S GROUP BY SUBMISSION_DATE, S.HACKER_ID),
T3 AS
(SELECT SUBMISSION_DATE,MAX(MY_COUNT) AS "MAX_COUNT" FROM T1 GROUP BY SUBMISSION_DATE),
T2 AS
(SELECT X.SUBMISSION_DATE, MY_COUNT, X.HACKER_ID, NAME
FROM T1 X, HACKERS D, T3 Z
WHERE Z.SUBMISSION_DATE = X.SUBMISSION_DATE
      AND X.MY_COUNT = Z.MAX_COUNT 
      AND D.HACKER_ID = X.HACKER_ID ),
T4 AS      
(SELECT SUBMISSION_DATE, MIN(HACKER_ID) AS "MY_HACKER" FROM T2 GROUP BY SUBMISSION_DATE ORDER BY SUBMISSION_DATE)
SELECT T2.SUBMISSION_DATE,T2.MY_COUNT, T2.HACKER_ID, T2.NAME FROM T2, T4 
WHERE T2.HACKER_ID = T4.MY_HACKER AND T2.SUBMISSION_DATE = T4.SUBMISSION_DATE;

*/
