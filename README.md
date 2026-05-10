# dongsam-summary

Turn any tech article (URL or pasted text) into a Korean **5-bullet abstract + structured long-form** summary.

## How to use

| Host | One-line setup |
|---|---|
| **Claude Code** | `unzip dist/dongsam-summary.zip -d ~/.claude/skills/` &nbsp;→&nbsp; trigger with `dongsam-summary <url>` |
| **Claude Desktop / claude.ai** | upload `dist/dongsam-summary.skill` via **Settings → Skills** |
| **ChatGPT (Custom GPT)** | paste `dist/prompt.md` into **Configure → Instructions** |
| **Gemini (Gem)** | paste `dist/prompt.md` into the Gem's **system instructions** |
| **Codex / Cursor / other agents** | paste `dist/prompt.md` as the system prompt or drop it as `AGENTS.md` |

For short-only output, just say "짧게" / "short".

## Example use case

> "https://blog.example.com/post  dongsam-summary"
> "이 글 짧게 요약해줘  <pasted markdown>"
> "long-form 요약: <url>"

## Example output

**Phase A — 5-bullet abstract**

```
- **VSCode의 잦은 AI 기능 추가와 불안정성**으로 기존 사용자 경험이 저하되며 새로운 대안을 찾게 된 사례
- **Zed**는 Rust로 작성된 **가볍고 빠른 IDE**로, VSCode 사용자에게 익숙한 UI와 키 바인딩 제공
- Python 환경 설정 시 **Basedpyright 타입 검사 모드** 혼란이 있었으나 pyproject.toml 설정으로 해결
- **Zed의 속도·안정성·단순한 설정**이 주요 장점, 확장 생태계는 작지만 일상 개발에는 충분
- **VSCode 독점에 도전할 수 있는 경쟁 IDE**로 부상, 개발자 중심의 가벼운 워크플로 회복
```

**Phase B — long-form** (full mode adds 5–8 `##` sections, 3–7 bullets each):

```
## VSCode에서 벗어나게 된 이유
  * AI 기능 중심 업데이트 이후 매 버전마다 **새로운 기능 비활성화** 필요
    * Copilot 미사용에도 "cmd+I to continue with Copilot" 메시지 반복
  * settings.json이 **비활성화 설정 목록**으로 길어지고 잦은 버그·크래시 발생

## Zed 첫인상 및 기본 설정
  * VSCode에서 전환 시 **UI와 키 바인딩이 유사**해 즉시 익숙한 환경 제공
  * 필요 설정: **폰트 크기·테마·Git blame 비활성화·자동 저장** 정도로 단순
...
```

## Layout

```
skill/SKILL.md          canonical skill definition
dist/dongsam-summary.zip   Claude Code bundle (unzip into ~/.claude/skills/)
dist/dongsam-summary.skill same archive, .skill extension for claude.ai
dist/prompt.md          flat system prompt for ChatGPT / Gemini / Codex / etc.
scripts/build_skill_package.sh  rebuild dist/ from skill/SKILL.md
```

---

*Style inspired by **GeekNews GN+** (news.hada.io).*
