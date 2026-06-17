# A3 — Validation Log (governance record)

*The AI drafted the reconciliation SQL (`reconciliation.sql`). **I governed it** — read each query, ran it against the two books, and confirmed it catches the right breaks and nothing it shouldn't. Verified 2026-06-16.*

## Did each query catch its break? (run vs. answer key)

| # | Break type | Expected (answer key) | Query returned | ✓ |
|---|---|---|---|---|
| 1 | Amount break (×2) | L-1003 / Meridian; L-1014 / Summit (LC) | both caught — L-1003 $1.0M, L-1014 $500K | ✓ |
| 2 | Missing in agent (×2) | L-1006 / Oakline; L-1013 / Oakline (LC) | both caught | ✓ |
| 3 | Missing in lender | L-1008 / Meridian Credit | L-1008 / Meridian Credit | ✓ |
| 4 | Duplicate | L-1002 / Pinnacle (recorded twice) | L-1002 / Pinnacle, count = 2 | ✓ |
| 5 | Stale date | L-1004 / Summit (06-12 vs 05-30) | L-1004 / Summit, dates differ | ✓ |
| 6 | Currency mismatch | L-1010 / Oakline (GBP vs USD) | L-1010 / Oakline, GBP vs USD | ✓ |

**All 6 break types (8 instances) caught. No breaks missed.**

## Edge cases I checked (the part that proves I read it, not just ran it)

- **Duplicate didn't create a false amount break.** L-1002/Pinnacle appears twice in the agent book; the amount-break join produces extra rows, but the amounts *match* (8.0M = 8.0M), so the `WHERE amount <> amount` filter correctly excludes it. It surfaces only under the duplicate check — correct.
- **Date variance that isn't a break stays quiet.** L-1001/Oakline (06-10) and L-1005/Meridian (06-11) carry off-cycle dates in *both* books — they are NOT flagged stale. Only a genuine mismatch (L-1004) trips. Correct.
- **Missing-in-lender catches the extra agent row.** The agent's L-1008 (Harbor Foods) has no lender match → flagged. Correct.
- **Clean non-USD reconciles silently.** L-1009 (Iberia Telecom / Meridian) is booked **EUR in both books** — it matches and is NOT flagged. Only the GBP-vs-USD disagreement (L-1010) trips the currency check. Correct.
- **New instrument types reconcile cleanly.** TLA (L-1011) and one LC (L-1012) match in both books and are NOT flagged — adding the instrument-type field created no false breaks; only the genuinely broken LCs (L-1013 missing, L-1014 amount) surface.
- **No false positives** anywhere else — clean positions reconcile silently.

## Read-only guardrail (proof, not claim)

Every query runs through `is_safe()` before execution. Verified:
- `SELECT * FROM lender_positions` → **allowed**
- `DROP TABLE lender_positions` → **BLOCKED** (refused before it can run)

So the tool can read and reconcile but can **never alter or delete** a position book.

## What's NOT covered yet (honest limits → v2)

- **Currency mismatch** — now **COVERED (v1):** detects same-position currency disagreements (L-1010, GBP vs USD); a clean EUR match (L-1009) confirms no false positives. *Next:* FX-rate-aware comparison (convert, then compare true value) — not just currency-code mismatch.
- **Partial fills / many-to-many** — one position per (loan_id, lender) assumed; real books split allocations.
- **Fuzzy keys** — exact key match only; real agent vs lender data has naming/ID drift that needs normalization first.
- **Scale + performance** — this is ~20 positions; real reconciliation runs millions, where indexing and batching matter.

*This is what I'd tell a team: it works on the happy path + the five classic breaks; here's exactly where it would need hardening before production.*
