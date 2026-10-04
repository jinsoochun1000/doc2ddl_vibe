# 이력서 DB화 (Oracle DDL)

`이력서.docx`(개인이력카드 + SKILL INVENTORY)를 Oracle 스키마로 모델링한 결과입니다.

- 파일: [resume_ddl.sql](resume_ddl.sql) — DROP, CREATE TABLE, 인덱스, 코멘트, 원본 데이터 INSERT 포함
- DBMS: Oracle 12c 이상 (`GENERATED ALWAYS AS IDENTITY` 사용)

## 테이블 구성

| 테이블 | 원본 섹션 | 설명 |
|---|---|---|
| `RESUME_EMPLOYEE` | 인적사항 | 성명, 생년월일, 성별, 소속, 입사일, 부서, 직위, 병적, 연락처, 주소, 기타 S/W (PK `EMP_ID`) |
| `RESUME_EDUCATION` | 학력사항 | 학교, 전공, 입학/졸업일, 졸업상태 |
| `RESUME_CERTIFICATION` | 자격증명 | 자격증명, 취득일 |
| `RESUME_CAREER` | 경력(회사명/기간/직위/담당업무) | `END_DATE` NULL = 재직중 |
| `RESUME_TRAINING` | 교육명/시작일/종료일/기관 | 교육이력 |
| `RESUME_SKILL` | 보유기술 및 외국어능력 | 숙련도 A/B/C (CHECK), (EMP_ID, SKILL_NAME) 유니크 |
| `RESUME_PROJECT` | SKILL INVENTORY | 프로젝트명, 참여기간, 고객사, 근무회사, 역할, 개발환경(기종/OS/언어/DBMS/TOOL/통신/WAS), 수행업무 |

## 관계

`RESUME_EMPLOYEE` 1 : N 나머지 6개 테이블 (`EMP_ID` FK). 하위 테이블 조회용 인덱스를 `EMP_ID`에 생성했습니다.

## 설계 메모

- 기간은 `DATE`로 저장하고, 종료일이 시작일보다 빠르지 않도록 CHECK 제약을 둠.
- 개발환경 7개 항목은 원본 표 구조를 따라 `RESUME_PROJECT`의 개별 컬럼으로 두었음.
- 적재 데이터: 원본에 값이 있는 항목만 INSERT (학력 2건, 경력 3건, 기술 3건, 프로젝트 3건). 생년월일·성별·소속 등 비어있거나 자리표시자(`YYYY-MM-DD`)인 항목은 NULL.
- 자격증·교육이력은 원본이 비어 있어 데이터 없음.
- 원본 DOCX 내 성명(홍길동)과 회사/학교명(OOO 등)은 샘플 값 그대로 반영.

## 실행

```sql
sqlplus 사용자/비밀번호@DB @resume_ddl.sql
```
