# A3 — Questions I'd Bring to the Product Team

*Gaps the data surfaced during reconciliation that any fix has to answer. I built each question by reasoning through what a break type actually means — not from BSL expertise, from BA process-and-judgment thinking. I can walk through all three from first principles.*

## The three questions

**Q1 — Timing breaks (the threshold problem).**
> *"How long do we wait before a timing break becomes a real break worth escalating? We need a threshold rule or we'll chase ghosts."*
The reasoning: a stale `as_of_date` is often just a sync lag, not a true discrepancy. With no grace window, the team escalates breaks that would have cleared on their own — wasted cycles chasing ghosts. So: define the wait.

**Q2 — Fee / rate breaks (the ownership gap).**
> *"When a fee dispute surfaces, who goes back to the loan agreement — the agent or the lender? That ownership gap is where breaks go to die."*
The reasoning: on a floating-rate or fee disagreement, the loan agreement is the source of truth — but someone has to actually go read it and resolve. If it's unclear who owns that, the break just sits unresolved. So: assign the owner.

**Q3 — Trade settlement lag (the cutoff rule).**
> *"Do we have a defined cutoff rule for mid-cycle trades? If not, payment routing will keep breaking at the same seam."*
The reasoning: a position traded mid-cycle can land in one book before the other, breaking at the same point every cycle. Without a defined cutoff for how mid-cycle trades are handled, the same seam keeps failing. So: set the cutoff.

## Product-discovery questions (context before building anything)

*Beyond the breaks themselves — what I'd ask to understand how the reports are actually used:*

- "When are these reports run, and does the timing matter?"
- "Who is using these reports?"
- "What other reports exist besides breaks?"

## Why these hold up

Each came from reasoning through an example — timing lag, contract-as-source-of-truth, mid-cycle settlement — so I can defend all three cold. **No BSL expertise claimed.** This is process-and-judgment thinking applied to the domain: seeing the gap behind the break.

## The through-line

> *"The reconciliation found the breaks. This is what I'd bring to the product team next — three process gaps the data surfaced that any fix has to answer. I built those questions by reasoning through what each break type actually means."*
