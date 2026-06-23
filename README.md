# A3 — Syndicated Loan Position Reconciliation

## In 30 seconds

In BSL, multiple lenders fund a loan -- across disparate systems. Breaks occur due to lags in data and/or systems, no golden source, manual reconciliations, and too many points of failure. This proof-of-concept reconciles two position books, identifies break types, surfaces the exposure, and gives a decision-maker something they can act on — every query read, pressure-tested, validated, and run by a human.

**How to read this project:**

> *"Act 1 is the structured investigation — analysts should always do this, it's the baseline. Act 2 is where I thought like a product analyst. I used what I know about BSL to reason through what Versana would actually care about — counterparty patterns, instrument risk, currency exposure."*

## Status — SQL validation complete, independently confirmed (6/16/2026 + 6/23/2026)

The master reconciliation query (`master_reconciliation.sql`) was **built independently**, then **run and verified by Matt in DB Browser** — all **6 break types / 8 instances** surfaced, an exact match to `BREAKS_AnswerKey`. **Four Eye control held: no automated process ran the validation logic — Matt governed and ran it.**

Independently confirmed 6/23/2026 via Python diff against the original CSV source files — **8 for 8 match**. Three separate validation methods, one result.

## Validation architecture (how the integrity story holds)

This project has three independent validation layers — each using a different method, different tools, and different hands:

**Layer 1 — SQL clean-room build (6/16/2026)**
C and Matt built the reconciliation SQL from scratch in DB Browser — no CW involvement in the validation logic. Matt ran the master query himself. 8 break rows surfaced, exact match to the answer key. Four Eye control: the system that generated the data did not validate its own output.

**Layer 2 — Python code diff (6/23/2026)**
Independent Python script compared the original lender and agent CSVs directly — no SQL, no prior query logic. Result: 8 breaks, identical to the answer key across all 6 break types. Two methods, one truth.

**Layer 3 — Human visual review (6/23/2026)**
Matt reviewed both position tables row by row, eyes on raw data, no AI in the loop. Confirmed the same breaks independently. Caught a data drift issue between a working Excel copy and the original CSVs — original CSVs confirmed authoritative.

**Why this matters:** The same system that generated the synthetic data and wrote the answer key cannot be the only system that validates them. These three layers ensure the answer key is independently verified — not just internally consistent.

## The governance story (what this actually demonstrates)

The AI drafted the reconciliation SQL. **I governed it** — that's the whole point:

- **`reconciliation.sql`** — the AI-drafted break queries (what I read and approve).
- **`run_reconciliation.py`** — runs them through a **read-only guardrail** (only `SELECT` ever executes; `DROP`/`UPDATE` are refused). Proof, not a claim.
- **`master_reconciliation.sql`** — all six checks combined into one `UNION ALL` master query, every row labeled with its `break_type`. Run and verified by me in DB Browser (6/16): **8 break rows, exact match to the answer key.**
- **`VALIDATION_LOG.md`** — my record that I checked each query catches the right break (all 6 types / 8 instances), plus the edge cases I verified and the honest limits.
- **`ROLLUP_BoardView.md`** — the breaks summarized for a decision-maker: $ exposure, severity, the call to make. The "roll it up for the people who decide" move.

## The data

Two synthesized books — **`lender_positions.csv`** (22) and **`agent_positions.csv`** (22) — keyed on `loan_id` + `lender`, with `par_amount`, `as_of_date`, `currency`, and `instrument_type` (TLA / TLB / RCF / **LC**). **`BREAKS_AnswerKey.md`** documents the break types deliberately injected (incl. the new-instrument LC breaks), so every result is checkable.

**Why synthetic:** *"Real syndicated loan data is confidential — so I built a synthetic dataset that mirrors the break patterns a real reconciliation would surface. That's actually part of the skill."*

**How it was built:** synthetic data generation with **fault injection** — realistic position data across two books (lender + agent), **6 injected break types** (amount, missing-in-agent, missing-in-lender, duplicate, stale date, currency mismatch), **4 instrument types** (TLA, TLB, Revolver, LC) with **LC positions seeded at a higher break rate**, and **multi-currency** positions. Building synthetic data that behaves like the real thing is part of the skill.

**Named techniques:** Synthetic data generation · Fault injection.

## The two-act question set (`nl_queries.md`)

- **Act 1 — structured investigation:** counts, total exposure, amount mismatches, missing positions, duplicates.
- **Act 2 — my product-analyst questions:** foreign-currency exposure by bank, which banks break most, breaks by instrument, and whether LCs (the new instrument) break at a higher rate.

## The judgment doc (`JUDGMENT_ProductSync.md`)

Three questions I'd bring to the product team — timing-break thresholds, fee/rate ownership, mid-cycle settlement cutoff — each reasoned from first principles. **I can defend all three cold.**

## Honest gaps

- **BSL is researched, not lived.** I understand the problem and built a POC to prove it; I don't claim hands-on syndicated-lending experience.
- **SQL is governed, not authored.** The AI drafts the queries; I read, validate, and guardrail them. That's the role I'm after — the human in the loop.
- **Data is synthesized** (controlled, with known breaks) — not real agent/lender feeds. The next step is real data + FX-aware comparison + scale.

## How to run & what's here

```bash
python run_reconciliation.py
```

Python 3, **standard library only** (no external packages). Loads the two CSV books into an in-memory SQLite database, runs the six break queries, prints the breaks, and demonstrates the read-only guardrail refusing a `DROP`.

**Read in this order:** `README.md` → `nl_queries.md` → `VALIDATION_LOG.md` → `ROLLUP_BoardView.md` → `JUDGMENT_ProductSync.md`.

**Files:**

- *Data* — `lender_positions.csv`, `agent_positions.csv` (the two books, 22 each); `BREAKS_AnswerKey.md` / `.xlsx` (the injected breaks — the checkable key)
- *Reconciliation* — `reconciliation.sql` (six break queries), `master_reconciliation.sql` (one UNION ALL master), `run_reconciliation.py` (runner + read-only `is_safe()` guardrail)
- *Governance & decision layer* — `VALIDATION_LOG.md`, `ROLLUP_BoardView.md`, `JUDGMENT_ProductSync.md`, `nl_queries.md`
