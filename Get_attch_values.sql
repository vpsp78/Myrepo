
CREATE OR REPLACE FUNCTION get_attachment_values(pv_attachments VARCHAR2)
  RETURN VARCHAR2
IS
  lv_v1 VARCHAR2(500);
  lv_v2 VARCHAR2(500);
  lv_j  VARCHAR2(500);
BEGIN
  lv_v1 := pv_attachments;
  FOR i IN (SELECT * FROM table(MS_APPS_UTILITIES.split_string(lv_v1,',')))
  LOOP 
    lv_j := '';
    lv_j := substr(i.column_value,1,instr(i.column_value,'#')-1);
    dbms_output.put_line(lv_j);
    IF lv_v2 IS NULL THEN
      lv_v2 := lv_j;
    ELSE
      lv_v2 := lv_v2||','||lv_j;
    END IF;
  END LOOP;
  RETURN lv_v2;
END get_attachment_values;
