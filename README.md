# AI Text Humanizer

A Claude Code skill that takes an essay that reads like AI wrote it and rewrites it so it reads like a person did, without changing what it says.

It does this by running eight open-source humanizer skills as one pipeline. Each of those skills catches different things, and they disagree with each other in places. The `essay-humanizer` skill decides who wins each disagreement, runs them in a fixed order, and checks the result by counting.

## What you get back

You give it an essay (pasted, or a file path). It gives you:

1. The rewritten essay. If you passed a file, it writes a new file next to it called `<name> (humanized).<ext>` and leaves the original alone.
2. A short report:

```
ai-check:  before 19/27  ->  after 4/27
slop-cop:  before 58 (D)  ->  after 91 (A)
Gate: dashes 0, semicolons 0, curly quotes 0, banned words 0, contrasts 0
Facts: all 14 numbers/names/dates/quotes/citations kept unchanged
Placeholders to fill: none
Cut: nothing substantive
```

(The numbers above are an illustration of the format.)

## How it works

| Step | What happens | Skills used |
|---|---|---|
| 0. Voice | If you paste samples of your own writing, or you've built a voice profile, the rewrite matches your habits. Otherwise it uses a plain essay register. | `write-in-my-voice` |
| 1. Score before | Rates the original on 9 AI signals (out of 27) and on a 100-point slop grade, quoting evidence for every point. | `ai-check`, `slop-cop` |
| 2. Rewrite | One pass that re-derives the prose from the content instead of swapping words. | `humanizer`, `humanize`, `no-slop`, `write-in-my-voice` |
| 3. Gate | Re-reads the draft and writes out literal counts: dashes, semicolons, curly quotes, banned words, "not X but Y" contrasts, one-line closers, forced triads, bold and headings. Then a fact diff: every number, name, date, quote, and citation in the original must still be there, unchanged. | all of the above |
| 4. Audit | Asks "what still reads as AI?", fixes 2 or 3 leftovers, re-runs the gate. Once only, because a second loop flattens the prose. | `humanize` |
| 5. Score after | Same scoring as step 1, on the final essay. | `ai-check`, `slop-cop` |

## Rules it won't break

These override every bundled skill:

- **Nothing invented.** No new facts, numbers, names, quotes, sources, or made-up personal anecdotes. Some humanizer tricks add fake specifics ("in the cases I've seen...") to sound human. This skill turns those off. If a sentence needs a detail it doesn't have, it leaves a `[placeholder]` and lists it for you.
- **Quotes, citations, and the bibliography are frozen.**
- **The argument is frozen.** Same thesis, same order of claims, same conclusion. Only the prose changes.
- **It edits for readers, not detectors.** It skips the paraphrase-loop and detector-gaming tricks that some skills include, since they add drift and make the essay worse.
- **Your voice beats the rules.** If your own writing uses dashes or semicolons, it keeps them.

## Install

You need [Claude Code](https://claude.com/claude-code).

```bash
git clone https://github.com/rlarbi438/ai-text-humanizer.git
cd ai-text-humanizer
./install.sh
```

`install.sh` copies each folder in `skills/` into `~/.claude/skills/`. It skips any skill you already have installed, so it won't overwrite your copies. Pass `--force` to replace them.

Or copy them by hand:

```bash
cp -R skills/* ~/.claude/skills/
```

Restart Claude Code after installing so it picks up the new skills.

## Use

In Claude Code, say any of:

- `humanize my essay` and paste it
- `run essay-humanizer on drafts/essay.md`
- `/essay-humanizer`

To have it match your own writing, paste a few paragraphs you wrote yourself along with the essay. For a reusable voice profile, run `calibrate-my-voice` once (or `personal-humanizer-maker` to generate a personal skill from a writing sample).

The bundled skills also work on their own. `ai-check` scores text, `slop-cop` grades and tickets it, `humanizer` and `humanize` rewrite it, and `no-slop` keeps Claude from writing slop in the first place.

## What's in the box

| Skill | What it does | Author | Source |
|---|---|---|---|
| `essay-humanizer` | The pipeline that runs everything below | rlarbi438 | this repo |
| `humanizer` | 26 AI-writing patterns, based on Wikipedia's "Signs of AI writing" | Siqi Chen (blader) | [blader/humanizer](https://github.com/blader/humanizer) |
| `humanize` | Rewrite levers, banned words, sentence-rhythm rules | Harshaneel Gokhale | [harshaneel/humanize](https://github.com/harshaneel/humanize) |
| `ai-check` | Scores text on 9 AI signals, 0 to 27 | Harshaneel Gokhale | [harshaneel/humanize](https://github.com/harshaneel/humanize) |
| `no-slop` | Banned vocabulary and writing rules for drafting | Byk3y | [Byk3y/no-slop](https://github.com/Byk3y/no-slop) |
| `slop-cop` | 100-point slop grade with evidence-backed "tickets" | Shannon Tran | [howshannon/slop-cop](https://github.com/howshannon/slop-cop) |
| `write-in-my-voice` | Rewrites in your calibrated voice | Yuval Meiri | [ymeiri/voice-layer](https://github.com/ymeiri/voice-layer) |
| `calibrate-my-voice` | Builds the voice profile from your own writing | Yuval Meiri | [ymeiri/voice-layer](https://github.com/ymeiri/voice-layer) |
| `personal-humanizer-maker` | Generates a personal humanizer skill from a writing sample | Taewoo Park | [TaewoooPark/personal-humanizer-maker](https://github.com/TaewoooPark/personal-humanizer-maker) |

All bundled skills are MIT licensed. Each folder keeps its original `LICENSE` file. Credit for those skills goes to their authors; go star their repos.

## A note on detectors

The scores measure writing patterns. They are not authorship detection, and they do not predict what Turnitin, GPTZero, or any other detector will say. The goal is an essay that reads better, not one that games a classifier.

## License

MIT for `essay-humanizer` and the repo itself (see [LICENSE](LICENSE)). Bundled skills keep their own MIT licenses in their folders.
