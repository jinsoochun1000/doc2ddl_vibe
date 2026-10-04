# 이력서 DB화 (Oracle DDL)

`../이력서.docx`(개인이력카드)를 Oracle 테이블로 옮긴 스키마와 데이터 적재 스크립트입니다.

## 파일

| 파일 | 내용 |
|------|------|
| [schema.sql](schema.sql) | DROP → CREATE TABLE/COMMENT/INDEX → 이력서 데이터 INSERT |

## 실행

```bash
sqlplus user/password@db @schema.sql
```

- 대상: **Oracle 12c 이상** (`GENERATED ALWAYS AS IDENTITY` 사용)
- 재실행 가능: 시작 시 기존 `RSM_*` 테이블을 DROP 후 재생성

## 테이블 구성

모든 테이블은 `RSM_PERSON` 1건을 부모로 갖는 1:N 구조입니다 (`ON DELETE CASCADE`).

```
RSM_PERSON (인적사항)
 ├─ RSM_EDUCATION   (학력사항)
 ├─ RSM_CERTIFICATE (자격증)
 ├─ RSM_CAREER      (경력사항)
 ├─ RSM_TRAINING    (교육이수)
 ├─ RSM_SKILL       (보유기술 및 외국어능력)
 └─ RSM_PROJECT     (프로젝트 수행이력)
```

| 테이블 | 이력서 항목 | 주요 컬럼 | 제약조건 |
|--------|-------------|-----------|----------|
| RSM_PERSON | 성명·생년월일·성별·소속회사·입사일자·부서·직위·병적·전화·E-Mail·주소·기타·작성자 | PERSON_NAME, BIRTH_DATE, GENDER, ADDRESS, ETC_SKILLS | GENDER ∈ (M,F) |
| RSM_EDUCATION | 학력사항 | SCHOOL_NAME, MAJOR_NAME, ADMISSION_DATE, GRADUATION_DATE, GRAD_STATUS | |
| RSM_CERTIFICATE | 자격증명/취득일 | CERT_NAME, ACQUIRED_DATE | |
| RSM_CAREER | 회사명·기간·직위·담당업무 | COMPANY_NAME, START_DATE, END_DATE, POSITION_NAME, DUTY_DESC | END_DATE ≥ START_DATE, NULL=재직중 |
| RSM_TRAINING | 교육명·시작일·종료일·기관 | TRAINING_NAME, START_DATE, END_DATE, INSTITUTION | |
| RSM_SKILL | 보유기술·숙련도 | SKILL_NAME, PROFICIENCY | 숙련도 ∈ (A,B,C), (PERSON_ID, SKILL_NAME) UNIQUE |
| RSM_PROJECT | 프로젝트명·참여기간·고객사·근무회사·역할·개발환경(기종/OS/언어/DBMS/TOOL/통신/WAS)·수행업무 | PROJECT_NAME, START_DATE, END_DATE, CLIENT_NAME, WORK_COMPANY, ROLE_NAME, ENV_*, TASK_DESC | END_DATE ≥ START_DATE |

컬럼별 한글 설명은 `COMMENT ON`으로 DB에 함께 등록됩니다.

## 적재된 데이터

| 테이블 | 건수 | 내용 |
|--------|-----:|------|
| RSM_PERSON | 1 | 홍길동, 경기도 화성시, 기타: CREO/AutoCAD/SolidWorks |
| RSM_EDUCATION | 2 | OOO고등학교(인문계 이과), OO대학교(XXX공학과) |
| RSM_CERTIFICATE | 0 | 문서에 기재 없음 |
| RSM_CAREER | 3 | OOO(대리) → OOOOO(선임) → OOOOOO(선임, 재직중) |
| RSM_TRAINING | 0 | 문서에 기재 없음 |
| RSM_SKILL | 3 | AutoCAD(A), CREO(B), SolidWorks(B) |
| RSM_PROJECT | 3 | LGD 파주공장 애플워치 셀자동화검사장비 구축 1~3단계 (설계, CAMERA 파트·프레임 설계) |

## 데이터 변환 규칙 / 가정

- 문서의 빈칸과 플레이스홀더(`YYYY-MM-DD`, `-`)는 **NULL**로 적재
- 경력 기간의 `재직중`은 `END_DATE = NULL`
- 프로젝트 개발환경은 문서 양식 그대로 항목별 컬럼(`ENV_*`)으로 두고, TOOL은 `'CREO, AutoCAD'`처럼 원문 문자열로 저장
- 성별은 `M/F` 코드로 정의 (문서에는 미기재)

## 조회 예시

```sql
SELECT p.PERSON_NAME, c.COMPANY_NAME, c.POSITION_NAME,
       c.START_DATE, NVL(TO_CHAR(c.END_DATE,'YYYY-MM-DD'),'재직중') AS END_DATE
  FROM RSM_PERSON p
  JOIN RSM_CAREER c ON c.PERSON_ID = p.PERSON_ID
 ORDER BY c.START_DATE;
```
