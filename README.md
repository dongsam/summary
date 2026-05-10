# dongsam-summary

Turn any tech article (URL or pasted text) into a Korean **5-bullet abstract + structured long-form** summary.

## How to use

**Claude Desktop**
- Open [`dist/dongsam-summary.skill`](https://github.com/dongsam/summary/raw/main/dist/dongsam-summary.skill) and execute it,
- or **Customize → Skills → Upload** [`dist/dongsam-summary.zip`](https://github.com/dongsam/summary/raw/main/dist/dongsam-summary.zip).

**Claude Code**

- Just chat: 
	```install skill https://raw.githubusercontent.com/dongsam/summary/main/skill/SKILL.md```
- or unzip [`dist/dongsam-summary.zip`](https://github.com/dongsam/summary/raw/main/dist/dongsam-summary.zip) into `~/.claude/skills/`.

**ChatGPT / Gemini / Codex / Cursor / other agents**
- Paste [`dist/prompt.md`](https://raw.githubusercontent.com/dongsam/summary/main/dist/prompt.md) as the system prompt (Custom GPT instructions, Gem system instructions, `AGENTS.md`, project rules, etc.).

For short-only output, just say "짧게" / "short".

## Example commands

```
/dongsam-summary <link>
/dongsam-summary 짧게 <link>
A, B, C 작업 처리하고 결과물 /dongsam-summary 로 요약 
```

```
dongsam-summary <link>
이 글 dongsam-summary 로 짧게 요약해줘 <link> or <pasted contents>
```

## Example output

```
/dongsam-summary
 https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
```

```markdown
- RAG가 매 질의마다 지식을 재합성하는 한계를 넘어, **LLM이 점진적으로 유지·갱신하는 영속적 마크다운 위키**를 raw 자료와 사용자 사이에 두는 패턴
- **raw·wiki·schema 3-layer 구조**로 분리되어 사용자는 큐레이션·질문을 담당하고 LLM이 요약·교차참조·일관성 유지를 전담
- **Ingest·Query·Lint** 세 운영으로 단일 ingest가 **10~15개 페이지**를 한 패스에 갱신, index.md·log.md 메타파일만으로 임베딩 RAG 없이 수백 페이지 규모 처리 가능
- 위키는 **lossy compression**이라 caveats·정확한 인용·minority view 손실 위험, provenance·access control·multi-user 결여로 대규모·고변동 KB에는 부적합
- 1945년 **Vannevar Bush의 Memex** 비전 중 미해결이던 "유지관리 주체" 문제를 LLM이 해소하는 패턴으로, Obsidian + Claude Code + git 조합으로 즉시 도입 가능

---

## 핵심 아이디어

  * 일반적 RAG는 매 질의마다 raw 문서에서 청크를 검색해 답변을 합성, **지식이 누적되지 않음**
  * LLM Wiki는 raw와 사용자 사이에 **persistent·compounding 마크다운 위키**를 두고, ingest 시점에 LLM이 정보를 추출·통합·교차참조 수행
  * 위키는 한 번 컴파일된 후 **지속 유지**되며 모순은 이미 플래그, 합성은 이미 반영, 매 질의마다 재도출 불필요
  * 사용자는 위키를 거의 직접 쓰지 않고 **소싱·탐색·질문**에 집중, 나머지 grunt work는 LLM이 담당
  * 실제 워크플로: 한쪽에 **Obsidian**(IDE), 다른 쪽에 LLM 에이전트(programmer), 위키가 codebase

## 3-layer 아키텍처

  * **Raw sources**: 큐레이션된 article·paper·image·data 컬렉션, immutable, LLM은 읽기만 가능한 source of truth
  * **The wiki**: LLM이 생성·소유한 마크다운 디렉터리 (entity·concept 페이지, summary, comparison, synthesis)
    * 페이지 생성, source 추가 시 갱신, 교차참조·일관성 유지 전담
    * 사용자는 읽기만 하며 직접 작성하지 않음
  * **The schema**: `CLAUDE.md` 또는 `AGENTS.md` 형태의 설정 문서
    * 구조·관례·workflow 규약을 명시해 LLM을 **disciplined wiki maintainer**로 만듦
    * 사용자-LLM이 시간에 따라 co-evolve하며 도메인 맞춤 조정
  * 책임 분리 명확화: 사용자는 **소싱·탐색·질문**, LLM은 **bookkeeping**(요약·교차참조·파일링) 담당

## 세 가지 운영

  * **Ingest**: raw에 신규 소스 드롭 후 LLM에 처리 지시
    * 요약 페이지 작성, 인덱스 갱신, 관련 entity·concept 페이지 갱신, 로그 추가
    * 단일 source가 **10~15개 페이지**를 동시에 터치
    * 한 건씩 sync 처리해 강조점 가이드, batch ingest 모드도 가능
  * **Query**: 위키에 질문 시 LLM이 관련 페이지 검색 후 인용 포함 답변 합성
    * 답변 형식: 마크다운 페이지, 비교 표, **Marp 슬라이드**, matplotlib 차트, canvas 등
    * 핵심: 좋은 답변은 다시 위키에 새 페이지로 파일링되어 탐색이 누적됨
  * **Lint**: 주기적 health-check 실행
    * contradiction, stale claim, orphan 페이지, 누락 cross-reference, data gap 탐지
    * LLM이 추가 조사할 질문·소스를 자율 제안

## 인덱싱과 로깅

  * **`index.md`** (content-oriented): 전 페이지 카탈로그, 1줄 요약과 메타데이터(date, source count)
    * entity·concept·source 카테고리로 조직, 매 ingest마다 갱신
    * 질의 시 LLM이 먼저 index를 읽고 관련 페이지로 drill-in
  * **`log.md`** (chronological): ingest·query·lint 이벤트 append-only 타임라인
    * `## [2026-04-02] ingest | <Title>` 일관 prefix 사용 시 `grep "^## \[" log.md | tail -5`로 최근 5건 파싱
  * **임베딩 RAG 없이** ~100 sources, 수백 페이지 규모까지 처리 가능, 모더레이트 스케일에서는 index 파일만으로 충분
  * 위키 성장 시 별도 search engine 도입으로 전환 가능 (qmd: BM25 + 벡터 + LLM rerank 하이브리드, on-device)

## 도구·워크플로 팁

  * **Obsidian Web Clipper**: 웹 article을 마크다운으로 변환해 raw 컬렉션에 빠르게 추가
  * 이미지 로컬 저장: attachment folder를 `raw/assets/`로 고정 후 "Download attachments" 단축키 바인딩, URL 깨짐 방지
    * LLM은 인라인 이미지를 한 패스에 못 읽음, 텍스트 read 후 이미지 별도 view
  * **Obsidian Graph view**: 허브·orphan 페이지 시각화로 위키 형태 파악
  * **Marp**: 마크다운 기반 슬라이드 포맷, 위키 콘텐츠에서 직접 발표자료 생성
  * **Dataview**: YAML frontmatter(태그·날짜·source count)로 동적 테이블·리스트 자동 생성
  * 위키는 **마크다운 git repo**라 버전관리·branching·협업이 무료로 따라옴

## 유효성과 한계

  * 핵심 동력: KB 유지비용은 reading·thinking이 아닌 **bookkeeping**(cross-reference, summary 갱신, 일관성)에 집중
    * 인간은 maintenance burden 때문에 위키를 포기, LLM은 한 패스에 15개 파일 touch 가능
    * 1945년 **Vannevar Bush의 Memex** 비전 중 미해결이던 "유지관리 주체"를 LLM이 해소
  * 댓글 비판(a-a-k): lossy compression이라 **caveats·minority view·exact wording** 누락 가능, derived 페이지만 조회 시 요약 오류가 KB에 고착
  * **production 이슈 미해결**: provenance, span-level citation, regression test, multi-user, audit log, rollback, sensitive data, access control, cost, latency
  * 적합 영역: **소규모-중규모, slow-moving, human-curated** 코퍼스 (개인 저널, 도서 동반 위키, 연구 폴더, 팀 위키)
  * 댓글창 파생 구현체: **Kompl, SwarmVault, ΩmegaWiki, Aura, NEXUS, Link** 등 ingest·graph·MCP 통합 형태로 다수 등장
```

---

*Style inspired by **GeekNews GN+** (news.hada.io).*