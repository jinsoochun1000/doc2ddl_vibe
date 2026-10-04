# 이력서.docx → Oracle DDL

`../이력서.docx`(개인이력카드 + SKILL INVENTORY)의 항목을 Oracle 테이블로 정규화한 결과입니다.

## 파일

| 파일 | 내용 |
|---|---|
| `schema.sql` | 테이블 7개, PK/FK/CHECK/UNIQUE 제약, 컬럼 주석, FK 인덱스 |
| `data.sql` | 원본 문서 내용 INSERT (PL/SQL 블록, 1건의 인적사항 기준) |

## 실행

Oracle 12c 이상 (IDENTITY 컬럼 사용). DB 문자셋은 AL32UTF8 권장.

```sql
@schema.sql
@data.sql
```

## 테이블 구조

```
RSM_PERSON (1)
 ├─< RSM_EDUCATION     학력사항
 ├─< RSM_CERTIFICATE   자격증
 ├─< RSM_CAREER        경력사항
 ├─< RSM_TRAINING      교육이수
 ├─< RSM_SKILL         보유기술 및 외국어능력
 └─< RSM_PROJECT       프로젝트 이력 (SKILL INVENTORY)
```

모든 하위 테이블은 `PERSON_ID`로 `RSM_PERSON`을 참조하며 `ON DELETE CASCADE`입니다.

| 테이블 | 문서 섹션 | 주요 컬럼 |
|---|---|---|
| `RSM_PERSON` | 개인이력카드 상단, 기타 S/W | 성명, 생년월일, 성별, 소속회사, 입사일자, 부서, 직위, 병적, 전화, E-Mail, 주소, 기타 S/W, 작성자 |
| `RSM_EDUCATION` | 학력사항 | 학교명, 전공, 입학일자, 졸업일자, 졸업구분 |
| `RSM_CERTIFICATE` | 자격증 | 자격증명, 취득일 |
| `RSM_CAREER` | 경력 | 회사명, 시작일, 종료일, 직위, 담당업무 |
| `RSM_TRAINING` | 교육 | 교육명, 시작일, 종료일, 기관 |
| `RSM_SKILL` | 보유기술 및 외국어능력 | 기술명, 숙련도(A/B/C) |
| `RSM_PROJECT` | SKILL INVENTORY | 프로젝트명, 참여기간, 고객사, 근무회사, 역할, 개발환경(기종/OS/언어/DBMS/TOOL/통신/WAS), 수행업무 |

## 설계 결정

- **기간 분리**: 문서의 `2019.04.01 ~ 2023.07.31` 형태는 `START_DT`/`END_DT` DATE 두 컬럼으로 나눔. `재직중`은 `END_DT = NULL`.
- **개발환경**: 문서의 7개 하위 칸(기종~WAS)을 `ENV_*` 컬럼으로 그대로 둠. 값이 자유 텍스트(`CREO, AutoCAD`)라 별도 코드 테이블로 분리하지 않음.
- **기타(활용가능한 S/W)**: 사람당 한 칸이라 `RSM_PERSON.ETC_SW`에 저장.
- **빈 항목**: 자격증·교육은 원본에서 비어 있지만 양식에 있는 항목이라 테이블만 생성. 자리표시자 값(`YYYY-MM-DD`, `-`)은 NULL로 적재.
- **제약**: 숙련도 `A/B/C`, 성별 `M/F`, 종료일 ≥ 시작일을 CHECK로 검증. 한 사람의 같은 기술 중복은 UNIQUE로 막음.

## 적재 데이터 요약

| 테이블 | 건수 |
|---|---|
| RSM_PERSON | 1 (홍길동) |
| RSM_EDUCATION | 2 |
| RSM_CAREER | 3 |
| RSM_SKILL | 3 |
| RSM_PROJECT | 3 |
| RSM_CERTIFICATE / RSM_TRAINING | 0 |
