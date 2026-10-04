-- Source: ../이력서.docx
-- This seed contains only values present in the source document.
-- Redacted/sample labels are preserved as shown; blank or placeholder-only
-- personal fields are stored as NULL. IDs are explicit for this sample load.

INSERT INTO resume_profile (
    resume_id, full_name, birth_date, gender, affiliated_company, hire_date,
    department, job_title, military_status, phone, email, address
) VALUES (
    1, '홍길동', NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, '경기도 화성시'
);

INSERT INTO resume_education (
    education_id, resume_id, institution_name, major, education_type,
    start_date, end_date, completion_status
) VALUES (
    1, 1, 'OOO고등학교', '인문계 이과', NULL,
    DATE '2008-03-03', DATE '2011-02-09', '졸업'
);

INSERT INTO resume_education (
    education_id, resume_id, institution_name, major, education_type,
    start_date, end_date, completion_status
) VALUES (
    2, 1, 'OO대학교', 'XXX공학과', NULL,
    DATE '2011-03-02', DATE '2017-08-22', '졸업'
);

INSERT INTO resume_career (
    career_id, resume_id, company_name, start_date, end_date, is_current,
    job_title, responsibilities
) VALUES (
    1, 1, 'OOO', DATE '2019-04-01', DATE '2023-07-31', 'N',
    '대리', '기구설계 (CREO, AutoCAD)'
);

INSERT INTO resume_career (
    career_id, resume_id, company_name, start_date, end_date, is_current,
    job_title, responsibilities
) VALUES (
    2, 1, 'OOOOO', DATE '2023-08-03', DATE '2024-09-30', 'N',
    '선임', '기구설계 (CREO, AutoCAD)'
);

INSERT INTO resume_career (
    career_id, resume_id, company_name, start_date, end_date, is_current,
    job_title, responsibilities
) VALUES (
    3, 1, 'OOOOOO', DATE '2024-10-28', NULL, 'Y',
    '선임', '공정물류 기구설계'
);

INSERT INTO resume_skill (skill_id, resume_id, skill_name, proficiency)
VALUES (1, 1, 'AutoCAD', 'A');

INSERT INTO resume_skill (skill_id, resume_id, skill_name, proficiency)
VALUES (2, 1, 'CREO', 'B');

INSERT INTO resume_skill (skill_id, resume_id, skill_name, proficiency)
VALUES (3, 1, 'SolidWorks', 'B');

INSERT INTO resume_project (
    project_id, resume_id, project_name, start_date, end_date,
    client_name, company_name, project_role, platform, operating_system,
    programming_lang, dbms, communication, application_server, responsibilities
) VALUES (
    1, 1, 'LGD 파주공장 애플워치 셀자동화검사장비 구축 1단계',
    DATE '2019-09-01', DATE '2019-12-31', 'LGD', '소닉스', '설계',
    NULL, NULL, NULL, NULL, NULL, NULL,
    'CAMERA 파트 설계, 프레임 설계'
);

INSERT INTO resume_project_tool (project_id, tool_name)
VALUES (1, 'CREO');

INSERT INTO resume_project_tool (project_id, tool_name)
VALUES (1, 'AutoCAD');

INSERT INTO resume_project (
    project_id, resume_id, project_name, start_date, end_date,
    client_name, company_name, project_role, platform, operating_system,
    programming_lang, dbms, communication, application_server, responsibilities
) VALUES (
    2, 1, 'LGD 파주공장 애플워치 셀자동화검사장비 구축 2단계',
    DATE '2020-09-01', DATE '2020-12-31', 'LGD', '소닉스', '설계',
    NULL, NULL, NULL, NULL, NULL, NULL,
    'CAMERA 파트 설계, 프레임 설계'
);

INSERT INTO resume_project_tool (project_id, tool_name)
VALUES (2, 'CREO');

INSERT INTO resume_project_tool (project_id, tool_name)
VALUES (2, 'AutoCAD');

INSERT INTO resume_project (
    project_id, resume_id, project_name, start_date, end_date,
    client_name, company_name, project_role, platform, operating_system,
    programming_lang, dbms, communication, application_server, responsibilities
) VALUES (
    3, 1, 'LGD 파주공장 애플워치 셀 자동화 검사장비 구축 3단계',
    DATE '2021-09-01', DATE '2021-12-31', 'LGD', '소닉스', '설계',
    NULL, NULL, NULL, NULL, NULL, NULL,
    'CAMERA 파트 설계, 프레임 설계'
);

INSERT INTO resume_project_tool (project_id, tool_name)
VALUES (3, 'CREO');

INSERT INTO resume_project_tool (project_id, tool_name)
VALUES (3, 'AutoCAD');

COMMIT;
