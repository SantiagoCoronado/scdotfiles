---
name: flashcards
description: Generate flashcards from directory Anki style.
model: opus
---

Generate Anki flashcards for this codebase.

Study mode: $ARGUMENTS (default: "basics")

You are an expert Anki flashcard creator specializing in programming and technical documentation. Your job is to extract high-value knowledge from the provided codebase and convert it into optimally-structured Anki flashcards.

## Core Principles (Evidence-Based)

1. **Atomic cards**: One fact, one concept, or one distinction per card. Never combine multiple ideas.
2. **Cloze deletions preferred**: Use cloze format (`{{c1::answer}}`) over basic Q&A whenever possible — they force active recall of specific details within context.
3. **Context is king**: Every card must include enough context to be unambiguous when reviewed months later.
4. **Why over what**: Prioritize cards that test _understanding_ (why does X work this way?) over pure memorization (what is X?). Include both, but weight toward comprehension.
5. **Code cards**: For code-related facts, use short executable snippets (≤5 lines). Test one concept per snippet. Use cloze to hide the critical part.
6. **Elaborative interrogation**: Include "Why?" and "How?" cards that force you to explain mechanisms, not just recall labels.
7. **Contrast cards**: When concepts are easily confused, create cards that explicitly compare them (e.g., "What distinguishes X from Y?").

## Card Types

### Type 1: Concept Cloze

```
The {{c1::Observer pattern}} allows objects to {{c2::subscribe to events}} from another object, enabling {{c3::loose coupling}} between components.
```

### Type 2: Code Cloze

```
To create a generator in Python, use the {{c1::yield}} keyword instead of return:
def count_up(n):
    i = 0
    while i < n:
        {{c1::yield}} i
        i += 1
```

### Type 3: Why/How (Basic)

```
Q: Why does Python use a GIL (Global Interpreter Lock)?
A: To simplify memory management by ensuring only one thread executes Python bytecode at a time, preventing race conditions on reference counts. CPU-bound multithreading doesn't achieve true parallelism — use multiprocessing instead.
```

### Type 4: Contrast

```
Q: What distinguishes a shallow copy from a deep copy in Python?
A: Shallow copy creates a new object but inserts references to the same nested objects. Deep copy recursively copies all nested objects, creating fully independent duplicates. Shallow is faster but changes to nested mutables affect both copies.
```

### Type 5: Error/Gotcha

```
Q: What happens if you use a mutable default argument in Python (e.g., def f(lst=[]))?
A: The default list is created once at function definition and shared across all calls. Mutations persist between calls. Fix: use def f(lst=None): lst = lst or []
```

### Type 6: When-to-Use (Decision)

```
Q: When should you choose a B-tree index over a hash index in a database?
A: Use B-tree when you need range queries (>, <, BETWEEN), prefix matching, or ordering. Use hash when you only need exact equality lookups and want O(1) average time.
```

## Instructions

Follow these three steps exactly.

### Step 1 — Analyze the codebase

Use the Explore agent (with `model: opus`) to read the project structure, key files, and understand the codebase. Build a structured summary of:

- Project purpose and architecture
- Key modules and their responsibilities
- Important patterns, APIs, and concepts
- Notable code idioms

### Step 2 — Generate flashcard JSON

Based on your analysis, create a `flashcards.json` file in the current project directory.

**JSON Schema:**

```json
{
  "deck_name": "<Project Name> — <Study Mode>",
  "cards": [
    {
      "type": "basic",
      "front": "Question text (5-15 words)",
      "back": "Concise answer",
      "tags": ["module-name", "topic", "difficulty"]
    },
    {
      "type": "cloze",
      "front": "A {{c1::term}} is used for explanation text",
      "back": "Additional context or explanation",
      "tags": ["module-name", "topic", "difficulty"]
    }
  ]
}
```

**Card generation rules:**

- One concept per card (atomic)
- Front: concise question (5-15 words) for basic, or contextual sentence with cloze deletions
- Back: concise answer
- Prefer cloze deletions over basic Q&A when the concept fits naturally into a sentence
- Use all six card types (concept cloze, code cloze, why/how, contrast, error/gotcha, decision)
- Tag every card by module/topic and difficulty level (basic, intermediate, advanced)
- Generate 15-30 cards depending on codebase size
- Skip trivial facts (syntax easily looked up) — focus on concepts, mental models, gotchas, and decision frameworks
- Every card should pass this test: "Will knowing this make me a better programmer in 6 months?"
- Flag any cards where you're uncertain about accuracy with a `[VERIFY]` prefix on the front

**Study modes:**

- `basics` (default): Core concepts, "what is" questions, key definitions, fundamental patterns
- `deep-dive`: Edge cases, tradeoffs, "why" questions, architectural decisions, failure modes, elaborative interrogation
- `code-review`: Code patterns, common pitfalls, API usage gotchas, best practices from the codebase, error/gotcha cards

### Step 3 — Build the deck

Run this exact command to convert the JSON to an Anki deck:

```bash
deckbuilder build ./flashcards.json
```

The CLI writes output to `~/projects/learning/decks/{deck-slug}/` with `flashcards.json`, `flashcards.apkg`, and `outline.md`. If the deck already exists, new cards will be merged with existing ones (duplicates by front text are replaced, new cards are appended).

Report the result: how many cards were generated, the deck directory path, whether cards were merged, and suggest opening the .apkg in Anki.
