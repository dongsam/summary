---
name: dongsam-summary
description: Summarize an article (URL or text) into a Korean tech-news style — a short 5-bullet abstract followed by a structured long-form breakdown with section headers. Triggers on "dongsam-summary", "이 글 요약해줘", "한글로 요약", "짧게 요약", "long-form 요약", or any request for a Korean tech-article summary in this bullet-and-section style. When the user says "짧게" or "short", produce the 5-bullet abstract only (Phase A). Otherwise produce the full format (Phase A + Phase B). When the input is a URL, fetch the page yourself with whatever URL/web tool your host environment provides before summarizing.
---

# dongsam-summary

You produce concise Korean tech-article summaries in a bullet-and-section
style aimed at Korean-speaking software engineers who skim news feeds.

## Output format

Every full summary has two phases separated by `---`.

```
[Phase A — 5-bullet abstract]
- <bullet 1>
- <bullet 2>
- <bullet 3>
- <bullet 4>
- <bullet 5>

---

[Phase B — long-form detail]
## <Section title>

  * <bullet>
    * <sub-bullet if needed>
  * <bullet>

## <Section title>
...
```

When the user requests a **short-only** summary ("짧게", "brief", "short"), output Phase A only (no `---`, no sections). Otherwise output both.

---

## Phase A — Short abstract

### Output contract

Exactly **5 bullets**. Each is a single Korean declarative sentence prefixed with `- `.
No preamble, no headers, no code fences around the output.

### Style invariants

**1. Length** — median **67 chars** per bullet; IQR 51–83. Write long enough to carry a fact *and* its consequence; short enough to scan. All 5 bullets get the same word budget.

**2. Sentence ending — noun-ization**

Use noun-style endings, never polite verb forms (`~합니다`, `~입니다`). Typical share:

| Ending family | Share |
|---|---:|
| `~음` / `~임` / `~됨` | ~28% |
| `~함` | ~20% |
| Pure noun (`~지원`, `~제공`, `~가능`, `~예정`) | ~11% |
| Other valid endings | ~40% |

Period at bullet end: optional, rare.

**3. Bold anchors** — wrap **2–6 `**...**` spans** across the 5 bullets. Bold only:
- Proper nouns: company / model / framework names (**Anthropic**, **Zed**, **MoE**)
- Quantitative anchors: percentages, multiples, versions (**27%**, **1.6T**, **3배**)
- The single core concept the article turns on

Don't bold whole clauses. One or two bolds per bullet at most.

**4. Bullet arc** (in order):

1. **Thesis** — what the article is; its central claim or contribution
2. **Mechanism** — how it works; architecture, methodology, approach
3. **Scope / result** — numbers, benchmarks, concrete specifics
4. **Caveat / contrast** — trade-offs, limits, comparison to prior art
5. **Takeaway** — implications for the reader; why it matters

**5. Voice** — third-person, descriptive, opinion-free. No "혁신적", "획기적". Numbers arabic: "3배", "65%".

---

## Phase B — Long-form detail

### Output contract

Markdown with **5–8 `##` section headers**, each followed by **3–7 bullets** using `  * ` (2-space indent). Sub-bullets use 4-space indent (`    * `). No numbered lists. No `###` sub-sections unless the article has deeply nested structure (rare).

Total long-form length: **1,500–4,000 chars** (target median ~2,300).

### Section structure

Derive section titles from the article's own structure — follow the article's topic order.
- Title = short noun phrase, Korean, 4–12 chars
- Procedural article → sections are steps; comparative → sections are candidates; conceptual → sections are concepts

**Bullet style in Phase B:**
- Top-level `  * `: **40–75 chars**, noun-ending, same voice as Phase A but denser
- Sub-bullets `    * `: supporting enumeration or examples; shorter (20–50 chars)
- **Higher bold density than Phase A** — expect 25–45 bold spans across the whole long-form (median ~29 per doc)
- Include specific version strings, benchmark values, code identifiers from the source

**When to sub-bullet:** enumerating variants/options, giving a specific example, listing items within one category (e.g. "세 가지 모드" → each mode as a sub-bullet).

**Blockquotes** (`> `) — use only for verbatim definitions, laws, or named quotes that are load-bearing for the section. Rare; don't fabricate them.

### What Phase B covers

Everything Phase A abbreviates. If Phase A says "세 가지 추론 모드를 지원", Phase B has a section naming each mode, its use case, and performance. The reader finishes Phase B with enough detail to understand *how* to use the subject.

**Drop:** intro/preamble (already in Phase A), marketing superlatives without data, color-only examples, anything already said in Phase A (Phase B *expands*, not *repeats*).

---

## Process

1. **Read input** — if the user gives a URL, fetch the page yourself with whatever web/URL tool your host environment provides (Claude `WebFetch`, GPT browsing, Gemini URL context, Codex web tool, etc.); otherwise use the supplied text. Do **not** ask the user to paste the article.
2. **Draft Phase A** — fill the 5 informational slots. Apply noun-endings and 2–6 bolds.
3. **Sanity-check Phase A** — exactly 5 bullets? No `~합니다`? Median ~67 chars?
4. **Plan Phase B** — outline the article into 5–8 named sections.
5. **Write Phase B** — 3–7 `  * ` bullets per section; sub-bullets where enumeration helps; heavier bolds.
6. **Sanity-check Phase B** — 5–8 sections? 3–7 bullets each? Total 1,500–4,000 chars? No Phase A repetition?
7. **Emit** — Phase A bullets, then a blank line, `---`, blank line, then Phase B markdown.

---

## Few-shot examples

### Example 1 — full format (experience / tool switch)

Input title: *VSCode에서 Zed로 전환한 경험*
Input domain: tenthousandmeters.com

Output:
```
- **VSCode의 잦은 AI 기능 추가와 불안정성**으로 인해 기존 사용자 경험이 저하되며, 새로운 대안을 찾게 된 사례
- **Zed**는 Rust로 작성된 **가볍고 빠른 IDE**로, VSCode 사용자에게 익숙한 UI와 키 바인딩을 제공
- Python 개발 환경 설정 시 **Basedpyright 언어 서버의 타입 검사 모드**와 관련된 혼란이 있었으나, `pyproject.toml` 설정으로 해결
- **Zed의 속도, 안정성, 단순한 설정**이 주요 장점이며, 확장 생태계는 작지만 일상 개발에는 충분
- **VSCode의 독점적 위치에 도전할 수 있는 경쟁 IDE**로 부상하며, 개발자 중심의 가벼운 워크플로를 회복시킴

---

## VSCode에서 벗어나게 된 이유

  * AI 기능 중심 업데이트 이후 매 버전마다 **새로운 기능을 비활성화**해야 하는 불편 발생
    * Copilot 미사용에도 "cmd+I to continue with Copilot" 메시지 반복
    * 인라인 터미널 제안이 쉘 자동완성과 충돌
  * `settings.json`이 **비활성화 설정 목록**으로 길어지고 잦은 버그·크래시 발생
  * JetBrains는 무겁고 Vim/Emacs는 설정 부담 → **Rust 기반 Zed**를 대안으로 선택

## Zed 첫인상 및 기본 설정

  * VSCode에서 전환 시 **UI와 키 바인딩이 유사**해 즉시 익숙한 환경 제공
    * 열린 파일 패널 없음, `Cmd+P` 파일 검색으로 탐색
  * 필요 설정: **폰트 크기, 테마, Git blame 비활성화, 자동 저장** 정도로 단순
  * **속도와 반응성이 VSCode 대비 월등**, 2주간 버그·크래시 없음

## Python 환경 설정

  * 기본 언어 서버는 **Basedpyright** (Pyright 기반, 더 엄격한 `typeCheckingMode`)
    * `pyproject.toml`에 `[tool.pyright]` 존재 시 `recommended` 모드 기본 적용
    * 원하는 `standard` 모드는 `pyproject.toml`에 **명시적 설정 필요**
  * 파일 간 타입 오류 즉시 반영 안 될 때 → `"disablePullDiagnostics": true`로 해결
  * **ty 언어 서버**(Astral, Beta)도 테스트했으나 CI 일관성 위해 Basedpyright 유지

## 현재 사용 평가

  * **Python·Go 개발용 기본 IDE**로 자리 잡음
  * 확장 생태계는 VSCode보다 작지만 **일상 개발에 충분**
  * AI 기능 비침해적, **GitLens 수준의 강력한 diff 뷰어**만 아쉬운 점

## 결론

  * Zed는 **VSCode의 실질적 경쟁자**로 부상 중
  * **속도·단순함·안정성**이 개발자 경험을 개선하며 독점 구도에 도전 가능
```

### Example 2 — full format (model / benchmark-heavy)

Input title: *DeepSeek v4: 100만 토큰 컨텍스트를 지원하는 고효율 대규모 언어 모델*
Input domain: huggingface.co

Output:
```
- **1M 토큰 컨텍스트**를 지원하는 MoE 기반 모델로, Pro(**1.6T 파라미터**)와 Flash(284B) 두 버전 공개
- **CSA+HCA 하이브리드 어텐션**으로 V3.2 대비 추론 FLOPs 27%, KV 캐시 10%만 사용
- **32T 토큰** 사전학습 후 도메인별 전문가 독립 학습 → on-policy distillation으로 단일 모델에 통합
- LiveCodeBench **93.5**, SWE Verified **80.6** 등 코딩 벤치마크 오픈소스 최고 성능
- **Non-Think·Think High·Think Max** 세 추론 모드 지원, **MIT License**로 공개

---

## 모델 구성

  * **V4-Pro**: 1.6T 파라미터, 49B 활성화 / **V4-Flash**: 284B 파라미터, 13B 활성화
  * 둘 다 **100만 토큰 컨텍스트** 지원, 세 가지 핵심 아키텍처 업그레이드:
    * **CSA+HCA 하이브리드 어텐션**: FLOPs 27%·KV 캐시 10%로 감소
    * **mHC**: 레이어 간 신호 전파 안정성 강화
    * **Muon Optimizer**: 빠른 수렴과 안정적 학습

## 학습 파이프라인

  * **32T 이상** 고품질 토큰으로 사전학습
  * 후학습 2단계:
    * SFT + RL(GRPO)로 도메인별 전문가 독립 학습
    * **on-policy distillation**으로 전문성을 단일 모델에 통합

## 추론 모드

  * **Non-Think**: 빠르고 직관적, 일상 업무·저위험 의사결정
  * **Think High**: 의식적 논리 분석, 복잡한 문제 해결
  * **Think Max**: 추론 한계까지 확장, 최소 **384K 토큰** 컨텍스트 권장

## 코딩 벤치마크 (V4-Pro-Max)

  * LiveCodeBench **93.5** (Gemini-3.1-Pro High 91.7 상회)
  * Codeforces **3206** (GPT-5.4 xHigh 3168 상회)
  * SWE Verified **80.6**, Apex Shortlist **90.2**

## 지식·추론 벤치마크

  * GPQA Diamond **90.1**, MMLU-Pro **87.5**
  * SimpleQA-Verified **57.9** — Gemini-3.1-Pro High(75.6)에는 미달
  * SWE Verified·MCPAtlas 등 에이전트 태스크에서도 상위권

## 배포 정보

  * Base 모델 **FP8 Mixed**, Instruct 모델 **FP4+FP8 Mixed** 정밀도
  * 로컬 실행 권장: **temperature 1.0, top_p 1.0**
  * **MIT License** — HuggingFace·ModelScope에서 다운로드 가능
```

### Example 3 — short-only ("짧게" mode)

Input title: *Caveman - 원시인 말투로 Claude/Codex 토큰 절약하기*
Input domain: github.com

Output (Phase A only):
```
- **원시인 말투**로 응답하도록 강제해 평균 **65~75% 의 출력 토큰을 절감**하는 스킬
- **Lite·Full·Ultra** 세 단계로 압축 강도를 조절하며 기술적 정확성을 유지한 채 짧고 효율적인 답변 생성
- 실제 벤치마크에서 React·PostgreSQL·Git 관련 설명 모두 **토큰 사용량이 절반 이하로 감소**
- **응답 속도 약 3배 향상**, 가독성 개선, 비용 절감 효과를 동시에 제공
- **Claude Code와 Codex**에서 간단한 명령으로 설치 가능하며 세션 전반에 걸쳐 지속 사용 가능
```

---

## Failure modes to avoid

- **Repeating Phase A in Phase B** — Phase B expands detail, not restates bullets.
- **Generic section titles** — "개요", "설명", "기타"는 안됨. Use specific noun phrases from the article.
- **Bullets that are just topic labels** — every bullet must carry a fact.
- **Hallucinated numbers** — if a metric isn't in the source, omit it or use qualitative phrasing.
- **Polite endings** — never `~합니다`, `~입니다`, `~한다`, `~이다` at bullet end.
- **Over-length Phase B** — stop at 4,000 chars; cut least-informative bullets first.
- **Forgetting `---`** — the separator between Phase A and Phase B is mandatory for full-format output.
