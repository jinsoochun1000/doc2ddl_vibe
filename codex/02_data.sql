-- 원본: ../이력서.docx. 01_schema.sql 실행 후 1회 적재합니다.
-- 재실행 시 같은 원본명으로 적재한 행이 있으면 중단합니다.
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
    v_resume_id resume.resume_id%TYPE;
    v_project_id resume_project.project_id%TYPE;
    v_existing NUMBER;

    PROCEDURE add_project (
        p_order NUMBER, p_name VARCHAR2, p_start DATE, p_end DATE
    ) IS
    BEGIN
        INSERT INTO resume_project (
            resume_id, display_order, project_name, start_date, end_date,
            customer_name, employer_name, role_name, responsibilities
        ) VALUES (
            v_resume_id, p_order, p_name, p_start, p_end,
            'LGD', '소닉스', '설계', 'CAMERA 파트 설계, 프레임 설계'
        ) RETURNING project_id INTO v_project_id;

        INSERT INTO resume_project_env (project_id, env_type, display_order, env_value)
        VALUES (v_project_id, 'TOOL', 1, 'CREO');
        INSERT INTO resume_project_env (project_id, env_type, display_order, env_value)
        VALUES (v_project_id, 'TOOL', 2, 'AutoCAD');
    END;
BEGIN
    SELECT COUNT(*) INTO v_existing FROM resume WHERE source_file = '이력서.docx';
    IF v_existing > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, '이력서.docx 데이터가 이미 있습니다. 중복 적재를 중단합니다.');
    END IF;

    INSERT INTO resume (source_file, full_name, address, other_skills)
    VALUES ('이력서.docx', '홍길동', '경기도 화성시', 'CREO, AutoCAD, SolidWorks')
    RETURNING resume_id INTO v_resume_id;

    INSERT INTO resume_education (
        resume_id, display_order, school_name, major_name, admission_date,
        graduation_date, graduation_status
    ) VALUES (
        v_resume_id, 1, 'OOO고등학교', '인문계 이과', DATE '2008-03-03', DATE '2011-02-09', '졸업'
    );
    INSERT INTO resume_education (
        resume_id, display_order, school_name, major_name, admission_date,
        graduation_date, graduation_status
    ) VALUES (
        v_resume_id, 2, 'OO대학교', 'XXX공학과', DATE '2011-03-02', DATE '2017-08-22', '졸업'
    );

    INSERT INTO resume_career (
        resume_id, display_order, company_name, start_date, end_date,
        is_current, position_name, responsibilities
    ) VALUES (
        v_resume_id, 1, 'OOO', DATE '2019-04-01', DATE '2023-07-31',
        'N', '대리', '기구설계 (CREO, AutoCAD)'
    );
    INSERT INTO resume_career (
        resume_id, display_order, company_name, start_date, end_date,
        is_current, position_name, responsibilities
    ) VALUES (
        v_resume_id, 2, 'OOOOO', DATE '2023-08-03', DATE '2024-09-30',
        'N', '선임', '기구설계 (CREO, AutoCAD)'
    );
    INSERT INTO resume_career (
        resume_id, display_order, company_name, start_date, end_date,
        is_current, position_name, responsibilities
    ) VALUES (
        v_resume_id, 3, 'OOOOOO', DATE '2024-10-28', NULL,
        'Y', '선임', '공정물류 기구설계'
    );

    INSERT INTO resume_skill (resume_id, display_order, skill_name, skill_type, proficiency)
    VALUES (v_resume_id, 1, 'AutoCAD', 'TECHNICAL', 'A');
    INSERT INTO resume_skill (resume_id, display_order, skill_name, skill_type, proficiency)
    VALUES (v_resume_id, 2, 'CREO', 'TECHNICAL', 'B');
    INSERT INTO resume_skill (resume_id, display_order, skill_name, skill_type, proficiency)
    VALUES (v_resume_id, 3, 'SolidWorks', 'TECHNICAL', 'B');

    add_project(1, 'LGD 파주공장 애플워치 셀자동화검사장비 구축 1단계', DATE '2019-09-01', DATE '2019-12-31');
    add_project(2, 'LGD 파주공장 애플워치 셀자동화검사장비 구축 2단계', DATE '2020-09-01', DATE '2020-12-31');
    add_project(3, 'LGD 파주공장 애플워치 셀 자동화 검사장비 구축 3단계', DATE '2021-09-01', DATE '2021-12-31');

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
PROMPT Source data load completed.
