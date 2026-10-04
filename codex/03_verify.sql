-- 적재 결과 점검: 읽기 전용. source_file이 이력서.docx인 데이터 기준.
SET DEFINE OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
    v_id NUMBER;
    v_count NUMBER;
    PROCEDURE expect_count(p_label VARCHAR2, p_actual NUMBER, p_expected NUMBER) IS
    BEGIN
        IF p_actual <> p_expected THEN
            RAISE_APPLICATION_ERROR(-20002, p_label || ': expected=' || p_expected || ', actual=' || p_actual);
        END IF;
        DBMS_OUTPUT.PUT_LINE(p_label || ': ' || p_actual || ' OK');
    END;
BEGIN
    SELECT COUNT(*), MIN(resume_id) INTO v_count, v_id
      FROM resume WHERE source_file = '이력서.docx';
    expect_count('resume', v_count, 1);
    SELECT COUNT(*) INTO v_count FROM resume_education WHERE resume_id = v_id;
    expect_count('education', v_count, 2);
    SELECT COUNT(*) INTO v_count FROM resume_certificate WHERE resume_id = v_id;
    expect_count('certificate', v_count, 0);
    SELECT COUNT(*) INTO v_count FROM resume_career WHERE resume_id = v_id;
    expect_count('career', v_count, 3);
    SELECT COUNT(*) INTO v_count FROM resume_training WHERE resume_id = v_id;
    expect_count('training', v_count, 0);
    SELECT COUNT(*) INTO v_count FROM resume_skill WHERE resume_id = v_id;
    expect_count('skill', v_count, 3);
    SELECT COUNT(*) INTO v_count FROM resume_project WHERE resume_id = v_id;
    expect_count('project', v_count, 3);
    SELECT COUNT(*) INTO v_count FROM resume_project_env e
      JOIN resume_project p ON p.project_id = e.project_id WHERE p.resume_id = v_id;
    expect_count('project_env', v_count, 6);
    SELECT COUNT(*) INTO v_count FROM resume
      WHERE resume_id = v_id AND birth_date IS NULL AND phone IS NULL AND email IS NULL;
    expect_count('placeholder_nulls', v_count, 1);
    SELECT COUNT(*) INTO v_count FROM resume_career
      WHERE resume_id = v_id AND is_current = 'Y' AND end_date IS NULL;
    expect_count('current_career', v_count, 1);
END;
/

SELECT r.full_name, p.display_order, p.project_name,
       TO_CHAR(p.start_date, 'YYYY-MM-DD') AS start_date,
       TO_CHAR(p.end_date, 'YYYY-MM-DD') AS end_date,
       p.customer_name, p.employer_name, p.role_name,
       e.env_type, e.env_value
  FROM resume r
  JOIN resume_project p ON p.resume_id = r.resume_id
  LEFT JOIN resume_project_env e ON e.project_id = p.project_id
 WHERE r.source_file = '이력서.docx'
 ORDER BY p.start_date, p.display_order, e.env_type, e.display_order;
