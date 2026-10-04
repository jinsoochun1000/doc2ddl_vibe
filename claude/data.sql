-- =====================================================================
-- 이력서.docx 내용 INSERT (schema.sql 실행 후 수행)
-- 원본에서 비어 있거나 자리표시자('-', 'YYYY-MM-DD')인 값은 NULL 처리
-- =====================================================================

DECLARE
    v_person_id RSM_PERSON.PERSON_ID%TYPE;
BEGIN
    -- 인적사항
    INSERT INTO RSM_PERSON (PERSON_NM, ADDRESS, ETC_SW)
    VALUES ('홍길동', '경기도 화성시', 'CREO, AutoCAD, SolidWorks')
    RETURNING PERSON_ID INTO v_person_id;

    -- 학력사항
    INSERT INTO RSM_EDUCATION (PERSON_ID, SCHOOL_NM, MAJOR_NM, ADMISSION_DT, GRADUATION_DT, GRAD_STATUS)
    VALUES (v_person_id, 'OOO고등학교', '인문계 이과', DATE '2008-03-03', DATE '2011-02-09', '졸업');
    INSERT INTO RSM_EDUCATION (PERSON_ID, SCHOOL_NM, MAJOR_NM, ADMISSION_DT, GRADUATION_DT, GRAD_STATUS)
    VALUES (v_person_id, 'OO대학교', 'XXX공학과', DATE '2011-03-02', DATE '2017-08-22', '졸업');

    -- 경력사항 (END_DT NULL = 재직중)
    INSERT INTO RSM_CAREER (PERSON_ID, COMPANY_NM, START_DT, END_DT, POSITION_NM, DUTY_DESC)
    VALUES (v_person_id, 'OOO', DATE '2019-04-01', DATE '2023-07-31', '대리', '기구설계 (CREO, AutoCAD)');
    INSERT INTO RSM_CAREER (PERSON_ID, COMPANY_NM, START_DT, END_DT, POSITION_NM, DUTY_DESC)
    VALUES (v_person_id, 'OOOOO', DATE '2023-08-03', DATE '2024-09-30', '선임', '기구설계 (CREO, AutoCAD)');
    INSERT INTO RSM_CAREER (PERSON_ID, COMPANY_NM, START_DT, END_DT, POSITION_NM, DUTY_DESC)
    VALUES (v_person_id, 'OOOOOO', DATE '2024-10-28', NULL, '선임', '공정물류 기구설계');

    -- 보유기술
    INSERT INTO RSM_SKILL (PERSON_ID, SKILL_NM, PROFICIENCY) VALUES (v_person_id, 'AutoCAD', 'A');
    INSERT INTO RSM_SKILL (PERSON_ID, SKILL_NM, PROFICIENCY) VALUES (v_person_id, 'CREO', 'B');
    INSERT INTO RSM_SKILL (PERSON_ID, SKILL_NM, PROFICIENCY) VALUES (v_person_id, 'SolidWorks', 'B');

    -- 프로젝트 이력 (SKILL INVENTORY)
    INSERT INTO RSM_PROJECT (PERSON_ID, PROJECT_NM, START_DT, END_DT, CLIENT_NM, WORK_COMPANY_NM, ROLE_NM, ENV_TOOL, TASK_DESC)
    VALUES (v_person_id, 'LGD 파주공장 애플워치 셀자동화검사장비 구축 1단계', DATE '2019-09-01', DATE '2019-12-31',
            'LGD', '소닉스', '설계', 'CREO, AutoCAD', 'CAMERA 파트 설계, 프레임 설계');
    INSERT INTO RSM_PROJECT (PERSON_ID, PROJECT_NM, START_DT, END_DT, CLIENT_NM, WORK_COMPANY_NM, ROLE_NM, ENV_TOOL, TASK_DESC)
    VALUES (v_person_id, 'LGD 파주공장 애플워치 셀자동화검사장비 구축 2단계', DATE '2020-09-01', DATE '2020-12-31',
            'LGD', '소닉스', '설계', 'CREO, AutoCAD', 'CAMERA 파트 설계, 프레임 설계');
    INSERT INTO RSM_PROJECT (PERSON_ID, PROJECT_NM, START_DT, END_DT, CLIENT_NM, WORK_COMPANY_NM, ROLE_NM, ENV_TOOL, TASK_DESC)
    VALUES (v_person_id, 'LGD 파주공장 애플워치 셀 자동화 검사장비 구축 3단계', DATE '2021-09-01', DATE '2021-12-31',
            'LGD', '소닉스', '설계', 'CREO, AutoCAD', 'CAMERA 파트 설계, 프레임 설계');

    COMMIT;
END;
/
