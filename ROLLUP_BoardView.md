# Position Reconciliation — Break Summary (as of 2026-06-16)

*Lender book reconciled against agent-bank book. Decision-ready view: what broke, the exposure, and the call to make.*

## Headline

- **22 lender positions reconciled** against the agent book.
- **8 breaks** found (6 types). **15 positions reconcile clean.**
- **$1.5M** direct par difference (two amount breaks) + notional across the missing, duplicated, and currency-mismatched positions.
- **Nothing auto-resolved** — every break is flagged for human sign-off before settlement/reporting.

## Breaks by type

| Break | Position | Notional at issue | Risk | Recommended action |
|---|---|---|---|---|
| **Amount break** | L-1003 Cedar Energy / Meridian | $1.0M difference (25.0M vs 24.0M) | **High** — settlement + reporting | Confirm authoritative book; resolve before settlement |
| **Missing in agent** | L-1006 Forge Materials / Oakline | $11.0M | **High** — possible unbooked trade | Confirm trade booked on agent side |
| **Missing in lender** | L-1008 Harbor Foods / Meridian | $8.5M | **High** — possible misallocation / wrong lender | Confirm who actually holds the position |
| **Duplicate** | L-1002 Beacon Health / Pinnacle | $8.0M (double-counted) | **Medium-High** — overstates agent book | De-dupe; confirm single booking |
| **Stale date** | L-1004 Delta Logistics / Summit | $15.0M (date 14 days old) | **Medium** — data freshness | Likely sync lag; refresh + re-run |
| **Currency mismatch** | L-1010 Britannia Retail / Oakline | $5.0M (GBP vs USD) | **High** — masks true position value | Confirm booking currency; FX-adjust and re-compare |
| **Amount break (LC)** | L-1014 Northgate Pharma / Summit | $0.5M difference | **High** — new-instrument face value | Confirm LC face value; resolve before settlement |
| **Missing in agent (LC)** | L-1013 Monarch Shipping / Oakline | $4.5M | **High** — new instrument not booked agent-side | Confirm LC onboarded to the agent's system |

**Instrument-type signal:** Both LC breaks sit on Letters of Credit — an instrument Versana added to its platform in May 2026, and exactly where the two sides' systems aren't aligned yet. Flag to product: **LC reconciliation coverage needs to be in place before LC volume grows.**

## The call

- **6 breaks need resolution before settlement** (2 amount, 3 missing, 1 currency) — they affect settlement and regulatory reporting.
- **2 are data-hygiene** (duplicate, stale date) — fix at the source so they stop recurring.
- **Confidence in the reconciled book: high for the 15 clean positions; the 8 breaks are contained and assigned.** That's the difference between "we don't trust the numbers till day 3–4" and "here's exactly what to chase, today."

*Of 22 lender positions, 7 are in breaks; +1 agent-only position (L-1008, missing-in-lender) = 8 break findings; 15 lender positions reconcile clean.*

*One line for the board: "22 positions reconciled, 8 breaks isolated and owned (incl. 2 on the new LC instrument), $1.5M par difference to resolve before settlement — no surprises