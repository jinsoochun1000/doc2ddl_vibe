# Word 이력서(DOCX) 기반 Oracle DDL 생성 모델별 비교 요약

본 저장소는 `이력서.docx`(개인이력카드 및 SKILL INVENTORY) 비정형 문서를 분석하여 **Oracle DBMS**용 DDL 스키마와 데이터 적재 스크립트를 작성한 8개 AI 코딩 모델/어시스턴트의 결과물을 비교·정리한 프로젝트입니다.

---

## 1. 모델별 비교 요약표

| 모델 / 폴더 | 테이블 수 | 루트 테이블 | 테이블 접두사 | 파일 구성 | 개발환경(TOOL 등) 모델링 | 주요 특징 및 차별점 |
|:---|:---:|:---|:---|:---|:---|:---|
| **[claude](claude)** | 7개 | `RSM_PERSON` | `RSM_` | `schema.sql`, `data.sql` | `RSM_PROJECT` 컬럼 (`ENV_*`) | 스키마와 데이터(PL/SQL 블록) 명확히 분리, 깔끔한 CHECK 제약조건 |
| **[claude_app](claude_app)** | 7개 | `RESUME_EMPLOYEE` | `RESUME_` | `resume_ddl.sql` | `RESUME_PROJECT` 컬럼 | DROP·DDL·인덱스·INSERT를 단일 스크립트에 통합한 간결한 구성 |
| **[claude_app_opus55](claude_app_opus55)** | 7개 | `RSM_PERSON` | `RSM_` | `schema.sql` | `RSM_PROJECT` 컬럼 (`ENV_*`) | 재실행 가능한 DROP-CREATE 단일 스크립트, 상세 조회 예시 쿼리 제공 |
| **[codex](codex)** | 8개 | `RESUME` | `RESUME_` | `01_schema.sql`<br>`02_data.sql`<br>`03_verify.sql` | **별도 테이블 분리**<br>(`RESUME_PROJECT_ENV`) | 스키마-적재-검증 3단계 파이프라인 분리, 개발환경 EAV 1:N 정규화, `RETURNING INTO` 활용 |
| **[codex_app](codex_app)** | 8개 | `RESUME_PROFILE` | `RESUME_` | `schema_oracle.sql`<br>`seed_resume.sql`<br>`verify_resume.sql` | **별도 테이블 분리**<br>(`RESUME_PROJECT_ENV`) | 개발환경 1:N 분리, Mermaid ERD 포함, 건수 검증 쿼리 및 트랜잭션 롤백 설계 |
| **[copilot](copilot)** | 8개 | `RESUME_PROFILE` | `RESUME_` | `schema.sql`, `seed.sql` | **TOOL만 분리**<br>(`RESUME_PROJECT_TOOL`) | 프로젝트 환경 중 TOOL만 1:N 자식 테이블로 추출하는 독특한 접근 |
| **[cursor](cursor)** | 7개 | `RESUME` | `RESUME_` | `schema.sql` | `RESUME_PROJECT` 컬럼 (`HW_MODEL` 등) | `SORT_ORDER` 정렬 순서 보존, 숫자형 `IS_CURRENT(0/1)` 제약, 올인원 실행 스크립트 |
| **[gemini](gemini)** | 7개 + 1뷰 | `TB_RESUME` | `TB_RESUME_` | `schema.sql` | `TB_RESUME_PROJECT` 컬럼 (`DEV_*`) | 엔터프라이즈 표준(`TB_`), PL/SQL 안전한 DROP(멱등성), 복합 인덱스, 감사 컬럼(`CREATED_AT`), 통합 조회 뷰(`VW_RESUME_OVERVIEW`) 제공 |

---

## 2. 세부 모델별 분석

### 1) [claude](claude) / [claude_app](claude_app) / [claude_app_opus55](claude_app_opus55)
- **공통점**: 1명의 이력서를 중심으로 7개 테이블(인적사항 + 학력/자격/경력/교육/스킬/프로젝트)로 1:N 정규화하였습니다.
- **차이점**:
  - `claude`: DDL(`schema.sql`)과 DML(`data.sql`)을 분리하여 표준 배포 형식을 갖춤.
  - `claude_app`: `resume_ddl.sql` 단일 파일로 신속한 원스톱 실행에 집중.
  - `claude_app_opus55`: DROP과 INSERT를 단일 `schema.sql`에 포함하고, README에 조회 예시 SQL 및 정밀한 마크다운을 제공.
- **설계 특징**: 프로젝트 개발환경(기종, OS, 언어, DBMS, TOOL, 통신, WAS)을 비정규화된 `ENV_*` 컬럼으로 유지하여 문서 형태를 직관적으로 보존했습니다.

### 2) [codex](codex) / [codex_app](codex_app)
- **핵심 차별점**: 프로젝트의 개발환경을 단일 컬럼에 쉼표로 넣지 않고, **`RESUME_PROJECT_ENV`라는 1:N 자식 테이블로 추가 정규화**하였습니다.
  - 원문의 `TOOL: CREO, AutoCAD`를 2개의 행(CREO / AutoCAD)으로 분리 적재하여 총 6행을 생성했습니다.
- **파이프라인화**:
  - `01_schema` (테이블/제약/주석) → `02_data / seed` (데이터 적재) → `03_verify` (적재 건수 및 무결성 자동 검증)의 3단계 스크립트 체계를 구축.
  - `RETURNING ... INTO` 구문으로 IDENTITY 생성 키를 동적으로 연결하여 시퀀스 시작값에 의존하지 않는 안전한 PL/SQL 적재를 구현했습니다.

### 3) [copilot](copilot)
- **핵심 차별점**: 개발환경의 7가지 항목 중 원본에 실제 데이터가 기재되어 있던 `TOOL` 항목에만 착안하여 **`RESUME_PROJECT_TOOL` 테이블을 독립적으로 분리**하고, 나머지 환경 항목은 프로젝트 테이블 컬럼으로 유지하는 절충형 방식을 선택했습니다.

### 4) [cursor](cursor)
- **핵심 차별점**: 
  - 각 상세 테이블에 `SORT_ORDER` 컬럼을 명시하여 원본 이력서 문서의 작성 순서(특히 최신 프로젝트가 하단에 위치하는 특성)를 정확히 보존했습니다.
  - 재직여부 플래그를 Oracle에서 자주 쓰이는 `CHAR(1)` 대신 숫자형 `IS_CURRENT IN (0, 1)`으로 제약했습니다.

### 5) [gemini](gemini)
- **핵심 차별점**:
  - **엔터프라이즈 컨벤션**: 국내 SI/엔터프라이즈 표준인 `TB_` 접두사를 테이블명에 적용 (`TB_RESUME`, `TB_RESUME_CAREER` 등).
  - **운영 안정성(멱등성)**: 단순 `DROP TABLE` 시 테이블 미존재 에러(ORA-00942)가 발생하지 않도록 `DECLARE ... EXCEPTION WHEN OTHERS THEN NULL` 방식의 PL/SQL 안전 드롭 블록 적용.
  - **성능 및 인덱스**: 외래키 잠금(Lock Contention) 방지 및 조회를 위한 복합 인덱스(`RESUME_ID`, `SORT_ORDER`) 생성.
  - **감사(Audit) 컬럼**: `CREATED_AT`, `UPDATED_AT` 시스템 관리 일시 반영.
  - **통합 뷰 제공**: 정규화된 7개 테이블을 즉시 한눈에 파악할 수 있는 `VW_RESUME_OVERVIEW` 뷰를 기본 제공.

---

## 3. 원본 문서 데이터 변환 공통 규칙

모든 모델이 공통적으로 준수한 데이터 정제 및 변환 규칙은 다음과 같습니다:

1. **자리표시자 및 빈값 처리**:
   - 생년월일의 서식 안내문(`YYYY-MM-DD`), 연락처의 `-`, 공백 셀은 데이터가 아닌 양식 안내문으로 판단하여 `NULL`로 처리.
   - 자격증 및 교육이수 항목은 양식 틀은 존재하나 내용이 비어 있어 테이블만 생성하고 `INSERT`는 수행하지 않음.
2. **원문 표기 무결성 유지**:
   - 성명(`홍길동`), 익명 회사(`OOO`, `OOOOO`, `OOOOOO`), 학교명(`OO대학교`, `XXX공학과`), 고객사(`LGD`), 근무회사(`소닉스`) 등 원본에 기재된 텍스트를 임의 변경 없이 보존.
3. **재직 상태 및 날짜 검증**:
   - `2024.10.28 ~ 재직중` 항목은 시작일자 저장, 종료일자 `NULL`, 재직여부 플래그(`Y` 또는 `1`)로 구조화.
   - 모든 날짜 컬럼에 대해 `종료일자 >= 시작일자` 검증 `CHECK` 제약조건 적용.
4. **Oracle 12c+ 현대적 DDL 사용**:
   - 과거 `SEQUENCE + TRIGGER` 조합 대신 `GENERATED ALWAYS/BY DEFAULT AS IDENTITY` 사용.
   - 한글 인코딩 깨짐 및 길이 오류 방지를 위해 바이트가 아닌 `VARCHAR2(n CHAR)` 단위 채택.

---

## 4. 디렉터리 구조

```text
doc2ddl_vibe/
├── 이력서.docx                 # 원본 Word 문서
├── prompt.md                   # 작업 요구사항 프롬프트
├── README.md                   # [본 문서] 모델별 종합 분석 및 비교 요약
├── claude/                     # Claude 기본 모델 (스키마/데이터 분리, 7테이블)
│   ├── README.md
│   ├── schema.sql
│   └── data.sql
├── claude_app/                 # Claude App (올인원 DDL, 7테이블)
│   ├── README.md
│   └── resume_ddl.sql
├── claude_app_opus55/          # Claude Opus 5.5 (단일 실행형, 7테이블)
│   ├── README.md
│   └── schema.sql
├── codex/                      # OpenAI Codex (3단계 파이프라인, 8테이블 환경 정규화)
│   ├── README.md
│   ├── 01_schema.sql
│   ├── 02_data.sql
│   └── 03_verify.sql
├── codex_app/                  # Codex App (8테이블 정규화, Mermaid ERD 및 검증)
│   ├── README.md
│   ├── schema_oracle.sql
│   ├── seed_resume.sql
│   └── verify_resume.sql
├── copilot/                    # GitHub Copilot (8테이블, TOOL 별도 분리)
│   ├── README.md
│   ├── schema.sql
│   └── seed.sql
├── cursor/                     # Cursor (SORT_ORDER 및 숫자 플래그, 7테이블)
│   ├── README.md
│   └── schema.sql
└── gemini/                     # Gemini (엔터프라이즈 TB_ 표준, 뷰 제공, 7테이블+1뷰)
    ├── README.md
    └── schema.sql
```

### Ai Model Version 
- claude : vsc - Opus 5.5
- claude_app : Sonnet 5.5
- claude_app_opus55 : Opus 5.5
- codex : vsc - GPT6-Astra 
- codex_app : GPT6-Astra
- copilot : 
- cursor : Grok 4.7
- gemini : gemini 3.8 flash