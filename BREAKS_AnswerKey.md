# A3 — Injected Breaks (Answer Key)

*Two tables — `lender_positions` vs `agent_positions` — keyed on `loan_id` + `lender`. **8 breaks (6 types) were injected on purpose.** Use this to check your reconciliation SQL. Don't peek until you've written the query.*

| # | Break type | Where (loan_id / lender) | Detail |
|---|---|---|---|
| 1 | **Amount break** | L-1003 / Meridian Credit (Cedar Energy RCF) | lender **25,000,000** vs agent **24,000,000** → $1.0M difference |
| 2 | **Stale date** | L-1004 / Summit CLO I (Delta Logistics TLB) | lender `as_of_date` 2026-06-12 vs agent **2026-05-30** |
| 3 | **Missing in agent** | L-1006 / Oakline Capital (Forge Materials TLB) | in the lender book, **absent from agent** |
| 4 | **Missing in lender** | L-1008 / Meridian Credit (Harbor Foods RCF) | in the agent book, **absent from lender** |
| 5 | **Duplicate** | L-1002 / Pinnacle Asset Mgmt (Beacon Health TLB) | recorded **twice** in the agent table |
| 6 | **Currency mismatch** | L-1010 / Oakline Capital (Britannia Retail RCF) | lender books **GBP**, agent books **USD** — same amount number, different currency, masks a true difference |
| 7 | **Amount break (LC)** | L-1014 / Summit CLO I (Northgate Pharma LC) | lender **6.0M** vs agent **5.5M** → $500K difference on a letter of credit |
| 8 | **Missing in agent (LC)** | L-1013 / Oakline Capital (Monarch Shipping LC) | booked lender-side; **not in the agent's book** — the new LC instrument isn't aligned across systems yet |

Everything else matches cleanly. **Currency is now active (promoted to v1):** one **clean EUR match** (L-1009 / Meridian, Iberia Telecom — both books EUR, *not* a break) proves non-USD reconciles, plus the **currency-mismatch break** above (L-1010).

**Date variance** (so the stale-date break stands out): rows at non-06-13 dates are L-1001/Oakline (06-10, both tables — *not* a break), L-1005/Meridian (06-11, both — *not* a break), and L-1004/Summit (the real stale-date break).

**Instrument type** added: **TLA** (amortizing), **TLB** (bullet/institutional), **RCF** (revolver), **LC** (letter of credit — added to Versana's platform in May 2026). The two newest breaks are seeded on **LCs** (L-1013 missing, L-1014 amount) — the new instrument is exactly where the two sides' systems aren't aligned yet. Clean reconcilers proving the types work: TLA **L-1011**, LC **L-1012**.

*Lender table = 22 positions · Agent table = 22 rows. **6 break TYPES, 8 instances** (amount ×2, missing-in-agent ×2, missing-in-lender, duplicate, stale, currency). Note: equal row counts ≠ reconciled — the 