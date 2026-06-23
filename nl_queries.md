# A3 — Talk to the Reconciliation in Plain English

*Ask a plain-English question about the two position books → the AI drafts the SQL → **I read and validate it (read-only)** → it runs and returns the answer. Two acts: the structured investigation any reconciliation runs, then the product-analyst questions I'd actually ask.*

## Act 1 — Structured investigation (the foundation)

*What any reconciliation analyst would run.*

| # | Plain-English question | SQL (validated) | Answer |
|---|---|---|---|
| 1 | "How many positions are in each book?" | `SELECT COUNT(*)` per table | lender **22**, agent **22** — equal counts ≠ reconciled (the breaks hide underneath) |
| 2 | "What's our total break exposure?" | `SUM(ABS(lend.par_amount-agt.par_amount))` on amount breaks | **$1.5M** (L-1003 $1.0M + L-1014 $0.5M) |
| 3 | "Which positions have an amount mismatch?" | `JOIN … WHERE lend.par_amount <> agt.par_amount` | **L-1003 / Meridian** (25M vs 24M) · **L-1014 / Summit (LC)** (6.0M vs 5.5M) |
| 4 | "Which positions are missing from the agent's book?" | `lend LEFT JOIN agt … WHERE agt IS NULL` | **L-1006 / Oakline** (TLB) · **L-1013 / Oakline (LC)** |
| 5 | "Are any positions double-booked?" | `GROUP BY loan_id,lender HAVING COUNT(*) > 1` | **L-1002 / Pinnacle** (recorded twice) |

## Act 2 — My questions (the product-analyst layer)

*What I added by reasoning through what a lead at a syndicated-loan platform would actually want to know.*

| # | Plain-English question | SQL (validated) | Answer |
|---|---|---|---|
| 6 | "Which loans are denominated in foreign currencies and which banks hold them?" | `WHERE currency <> 'USD'` | **L-1009 Iberia** (EUR, Meridian) · **L-1010 Britannia** (GBP, Oakline) |
| 7 | "Which banks show up most frequently in breaks and what break type are they associated with?" | break rows `GROUP BY lender` | **Oakline Capital — 3** (2 missing + 1 currency) · Meridian 2 (amount + missing) · Summit 2 (amount + stale) · Pinnacle 1 (duplicate) |
| 8 | "What instruments are tied to what breaks?" | break rows `GROUP BY instrument_type` | **TLB** 3 (missing, dup, stale) · **RCF** 3 (amount, missing, currency) · **LC** 2 (missing, amount) · TLA 0 |
| 9 | "Are Letters of Credit breaking more often than other instrument types?" | break rate `GROUP BY instrument_type` | *(open question — the one I'd bring to the team)* |

**How to read this project:** *"Act 1 is the structured investigation — analysts should always do this, it's the baseline. Act 2 is where I thought like a product analyst. I used what I know about BSL to reason through what Versana would actually care about — counterparty patterns, instrument risk, currency exposure."*

*Act-1 queries verified live via `run_reconciliation.py`; Act-2 aggregates computed from the data. Validated by Matt in DB Browser — exact match to BREAKS_AnswerKey.*
