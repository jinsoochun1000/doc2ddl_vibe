-- 이력서 데이터 모델 / Oracle Database 19c 기준 (IDENTITY 사용: 12c 이상)
-- SQL*Plus / SQLcl / SQL Developer의 스크립트 실행(F5)으로 실행합니다.
-- 기존 객체가 없는 접속 스키마에 1회 실행합니다. DDL은 자동 COMMIT됩니다.
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

CREATE TABLE resume (
    resume_id NUMBER GENERATED ALWAYS AS IDENTITY,
    source_file VARCHAR2(255 CHAR) NOT NULL,
    full_name VARCHAR2(100 CHAR) NOT NULL,
    birth_date DATE,
    gender VARCHAR2(30 CHAR),
    company_name VARCHAR2(200 CHAR),
    hire_date DATE,
    department_name VARCHAR2(200 CHAR),
    position_name VARCHAR2(100 CHAR),
    military_status VARCHAR2(100 CHAR),
    phone VARCHAR2(50 CHAR),
    email VARCHAR2(254 CHAR),
    address VARCHAR2(500 CHAR),
    author_name VARCHAR2(100 CHAR),
    other_skills CLOB,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_resume PRIMARY KEY (resume_id)
);

CREATE TABLE resume_education (
    education_id NUMBER GENERATED ALWAYS AS IDENTITY,
    resume_id NUMBER NOT NULL,
    display_order NUMBER(5) NOT NULL,
    school_name VARCHAR2(200 CHAR) NOT NULL,
    major_name VARCHAR2(200 CHAR),
    admission_date DATE,
    graduation_date DATE,
    graduation_status VARCHAR2(50 CHAR),
    CONSTRAINT pk_resume_education PRIMARY KEY (education_id),
    CONSTRAINT fk_education_resume FOREIGN KEY (resume_id) REFERENCES resume(resume_id),
    CONSTRAINT uq_education_order UNIQUE (resume_id, display_order),
    CONSTRAINT ck_education_order CHECK (display_order > 0),
    CONSTRAINT ck_education_dates CHECK (graduation_date >= admission_date)
);

CREATE TABLE resume_certificate (
    certificate_id NUMBER GENERATED ALWAYS AS IDENTITY,
    resume_id NUMBER NOT NULL,
    display_order NUMBER(5) NOT NULL,
    certificate_name VARCHAR2(200 CHAR) NOT NULL,
    acquired_date DATE,
    CONSTRAINT pk_resume_certificate PRIMARY KEY (certificate_id),
    CONSTRAINT fk_certificate_resume FOREIGN KEY (resume_id) REFERENCES resume(resume_id),
    CONSTRAINT uq_certificate_order UNIQUE (resume_id, display_order),
    CONSTRAINT ck_certificate_order CHECK (display_order > 0)
);

CREATE TABLE resume_career (
    career_id NUMBER GENERATED ALWAYS AS IDENTITY,
    resume_id NUMBER NOT NULL,
    display_order NUMBER(5) NOT NULL,
    company_name VARCHAR2(200 CHAR) NOT NULL,
    start_date DATE,
    end_date DATE,
    is_current CHAR(1 CHAR) DEFAULT 'N' NOT NULL,
    position_name VARCHAR2(100 CHAR),
    responsibilities CLOB,
    CONSTRAINT pk_resume_career PRIMARY KEY (career_id),
    CONSTRAINT fk_career_resume FOREIGN KEY (resume_id) REFERENCES resume(resume_id),
    CONSTRAINT uq_career_order UNIQUE (resume_id, display_order),
    CONSTRAINT ck_career_order CHECK (display_order > 0),
    CONSTRAINT ck_career_dates CHECK (end_date >= start_date),
    CONSTRAINT ck_career_current CHECK (is_current IN ('Y', 'N')),
    CONSTRAINT ck_career_open CHECK (is_current = 'N' OR end_date IS NULL)
);

CREATE TABLE resume_training (
    training_id NUMBER GENERATED ALWAYS AS IDENTITY,
    resume_id NUMBER NOT NULL,
    display_order NUMBER(5) NOT NULL,
    training_name VARCHAR2(300 CHAR) NOT NULL,
    start_date DATE,
    end_date DATE,
    institution_name VARCHAR2(200 CHAR),
    CONSTRAINT pk_resume_training PRIMARY KEY (training_id),
    CONSTRAINT fk_training_resume FOREIGN KEY (resume_id) REFERENCES resume(resume_id),
    CONSTRAINT uq_training_order UNIQUE (resume_id, display_order),
    CONSTRAINT ck_training_order CHECK (display_order > 0),
    CONSTRAINT ck_training_dates CHECK (end_date >= start_date)
);

CREATE TABLE resume_skill (
    skill_id NUMBER GENERATED ALWAYS AS IDENTITY,
    resume_id NUMBER NOT NULL,
    display_order NUMBER(5) NOT NULL,
    skill_name VARCHAR2(200 CHAR) NOT NULL,
    skill_type VARCHAR2(20 CHAR) DEFAULT 'TECHNICAL' NOT NULL,
    proficiency CHAR(1 CHAR),
    CONSTRAINT pk_resume_skill PRIMARY KEY (skill_id),
    CONSTRAINT fk_skill_resume FOREIGN KEY (resume_id) REFERENCES resume(resume_id),
    CONSTRAINT uq_skill_order UNIQUE (resume_id, display_order),
    CONSTRAINT uq_skill_name UNIQUE (resume_id, skill_type, skill_name),
    CONSTRAINT ck_skill_order CHECK (display_order > 0),
    CONSTRAINT ck_skill_type CHECK (skill_type IN ('TECHNICAL', 'LANGUAGE', 'OTHER')),
    CONSTRAINT ck_skill_proficiency CHECK (proficiency IN ('A', 'B', 'C'))
);

CREATE TABLE resume_project (
    project_id NUMBER GENERATED ALWAYS AS IDENTITY,
    resume_id NUMBER NOT NULL,
    display_order NUMBER(5) NOT NULL,
    project_name VARCHAR2(500 CHAR) NOT NULL,
    start_date DATE,
    end_date DATE,
    customer_name VARCHAR2(200 CHAR),
    employer_name VARCHAR2(200 CHAR),
    role_name VARCHAR2(100 CHAR),
    responsibilities CLOB,
    CONSTRAINT pk_resume_project PRIMARY KEY (project_id),
    CONSTRAINT fk_project_resume FOREIGN KEY (resume_id) REFERENCES resume(resume_id),
    CONSTRAINT uq_project_order UNIQUE (resume_id, display_order),
    CONSTRAINT ck_project_order CHECK (display_order > 0),
    CONSTRAINT ck_project_dates CHECK (end_date >= start_date)
);

CREATE TABLE resume_project_env (
    project_env_id NUMBER GENERATED ALWAYS AS IDENTITY,
    project_id NUMBER NOT NULL,
    env_type VARCHAR2(20 CHAR) NOT NULL,
    display_order NUMBER(5) NOT NULL,
    env_value VARCHAR2(300 CHAR) NOT NULL,
    CONSTRAINT pk_resume_project_env PRIMARY KEY (project_env_id),
    CONSTRAINT fk_project_env_project FOREIGN KEY (project_id) REFERENCES resume_project(project_id),
    CONSTRAINT uq_project_env_order UNIQUE (project_id, env_type, display_order),
    CONSTRAINT uq_project_env_value UNIQUE (project_id, env_type, env_value),
    CONSTRAINT ck_project_env_order CHECK (display_order > 0),
    CONSTRAINT ck_project_env_type CHECK (
        env_type IN ('HARDWARE', 'OS', 'LANGUAGE', 'DBMS', 'TOOL', 'COMMUNICATION', 'WAS')
    )
);

-- 자식 테이블의 (resume_id, display_order) UNIQUE 인덱스 및
-- 환경 테이블의 (project_id, env_type, display_order) UNIQUE 인덱스가 FK 조회를 지원합니다.
CREATE INDEX ix_project_start ON resume_project (resume_id, start_date);

COMMENT ON TABLE resume IS '개인 이력 카드 및 원본 문서 정보';
COMMENT ON COLUMN resume.resume_id IS '이력서 식별자, 자동 생성';
COMMENT ON COLUMN resume.source_file IS '원본 문서 파일명';
COMMENT ON COLUMN resume.full_name IS '성명';
COMMENT ON COLUMN resume.birth_date IS '생년월일, 양식 안내문은 NULL';
COMMENT ON COLUMN resume.gender IS '성별, 원문 표기';
COMMENT ON COLUMN resume.company_name IS '기본정보의 소속회사, 경력에서 추정하지 않음';
COMMENT ON COLUMN resume.hire_date IS '기본정보의 입사일자';
COMMENT ON COLUMN resume.department_name IS '부서';
COMMENT ON COLUMN resume.position_name IS '기본정보의 직위';
COMMENT ON COLUMN resume.military_status IS '병적';
COMMENT ON COLUMN resume.phone IS '전화';
COMMENT ON COLUMN resume.email IS 'E-Mail';
COMMENT ON COLUMN resume.address IS '주소';
COMMENT ON COLUMN resume.author_name IS 'SKILL INVENTORY 작성자, 미기재 시 NULL';
COMMENT ON COLUMN resume.other_skills IS '기타 활용가능한 S/W 및 기법, FrameWork 원문';
COMMENT ON COLUMN resume.created_at IS 'DB 레코드 생성시각, 문서 작성일과 무관';

COMMENT ON TABLE resume_education IS '학력사항';
COMMENT ON COLUMN resume_education.education_id IS '학력 식별자';
COMMENT ON COLUMN resume_education.resume_id IS '이력서 식별자';
COMMENT ON COLUMN resume_education.display_order IS '원문 표시 순서';
COMMENT ON COLUMN resume_education.school_name IS '학교명';
COMMENT ON COLUMN resume_education.major_name IS '전공 또는 계열';
COMMENT ON COLUMN resume_education.admission_date IS '입학일자';
COMMENT ON COLUMN resume_education.graduation_date IS '졸업일자';
COMMENT ON COLUMN resume_education.graduation_status IS '졸업 상태 원문';

COMMENT ON TABLE resume_certificate IS '자격증, 원본의 공란은 행을 생성하지 않음';
COMMENT ON COLUMN resume_certificate.certificate_id IS '자격증 식별자';
COMMENT ON COLUMN resume_certificate.resume_id IS '이력서 식별자';
COMMENT ON COLUMN resume_certificate.display_order IS '원문 표시 순서';
COMMENT ON COLUMN resume_certificate.certificate_name IS '자격증명';
COMMENT ON COLUMN resume_certificate.acquired_date IS '취득일';

COMMENT ON TABLE resume_career IS '회사별 경력';
COMMENT ON COLUMN resume_career.career_id IS '경력 식별자';
COMMENT ON COLUMN resume_career.resume_id IS '이력서 식별자';
COMMENT ON COLUMN resume_career.display_order IS '원문 표시 순서';
COMMENT ON COLUMN resume_career.company_name IS '회사명 원문';
COMMENT ON COLUMN resume_career.start_date IS '경력 시작일';
COMMENT ON COLUMN resume_career.end_date IS '경력 종료일, 재직중 또는 미상은 NULL';
COMMENT ON COLUMN resume_career.is_current IS '원문 재직중 여부 Y/N, 현재 날짜로 갱신하지 않음';
COMMENT ON COLUMN resume_career.position_name IS '직위';
COMMENT ON COLUMN resume_career.responsibilities IS '담당 업무 원문';

COMMENT ON TABLE resume_training IS '교육 이력, 원본의 공란은 행을 생성하지 않음';
COMMENT ON COLUMN resume_training.training_id IS '교육 식별자';
COMMENT ON COLUMN resume_training.resume_id IS '이력서 식별자';
COMMENT ON COLUMN resume_training.display_order IS '원문 표시 순서';
COMMENT ON COLUMN resume_training.training_name IS '교육명';
COMMENT ON COLUMN resume_training.start_date IS '교육 시작일';
COMMENT ON COLUMN resume_training.end_date IS '교육 종료일';
COMMENT ON COLUMN resume_training.institution_name IS '교육 기관';

COMMENT ON TABLE resume_skill IS '보유기술 및 외국어능력';
COMMENT ON COLUMN resume_skill.skill_id IS '보유능력 식별자';
COMMENT ON COLUMN resume_skill.resume_id IS '이력서 식별자';
COMMENT ON COLUMN resume_skill.display_order IS '원문 표시 순서';
COMMENT ON COLUMN resume_skill.skill_name IS '기술 또는 외국어명';
COMMENT ON COLUMN resume_skill.skill_type IS 'TECHNICAL 기술, LANGUAGE 외국어, OTHER 기타';
COMMENT ON COLUMN resume_skill.proficiency IS '원문 숙련도 A/B/C, 등급 의미는 원문에 정의 없음';

COMMENT ON TABLE resume_project IS 'SKILL INVENTORY 프로젝트 참여 이력';
COMMENT ON COLUMN resume_project.project_id IS '프로젝트 참여 식별자';
COMMENT ON COLUMN resume_project.resume_id IS '이력서 식별자';
COMMENT ON COLUMN resume_project.display_order IS '원문 순서, 최근 프로젝트를 하단에 표시';
COMMENT ON COLUMN resume_project.project_name IS '프로젝트명 또는 시스템명';
COMMENT ON COLUMN resume_project.start_date IS '참여 시작일';
COMMENT ON COLUMN resume_project.end_date IS '참여 종료일';
COMMENT ON COLUMN resume_project.customer_name IS '고객사';
COMMENT ON COLUMN resume_project.employer_name IS '프로젝트 근무회사 원문, 경력 회사와 임의 연결하지 않음';
COMMENT ON COLUMN resume_project.role_name IS '역할';
COMMENT ON COLUMN resume_project.responsibilities IS '수행업무 원문';

COMMENT ON TABLE resume_project_env IS '프로젝트 개발환경, 종류별 복수 값 저장';
COMMENT ON COLUMN resume_project_env.project_env_id IS '개발환경 항목 식별자';
COMMENT ON COLUMN resume_project_env.project_id IS '프로젝트 참여 식별자';
COMMENT ON COLUMN resume_project_env.env_type IS 'HARDWARE 기종, OS, LANGUAGE 언어, DBMS, TOOL, COMMUNICATION 통신, WAS';
COMMENT ON COLUMN resume_project_env.display_order IS '동일 종류 내 표시 순서';
COMMENT ON COLUMN resume_project_env.env_value IS '개발환경 값, 예: CREO';

PROMPT Schema creation completed.
