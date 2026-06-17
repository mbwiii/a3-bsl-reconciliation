"""
A3 — Syndicated Loan Position Reconciliation (runner + read-only guardrail)

Loads the two position books into SQLite, runs the AI-drafted reconciliation
queries, and prints the breaks. Every query passes through is_safe() first —
the GOVERNANCE guardrail: only read-only SELECTs ever execute.

Run:  python run_reconciliation.py     (needs: nothing beyond Python 3)
"""
import csv, sqlite3, os

HERE = os.path.dirname(os.path.abspath(__file__))

# ---- READ-ONLY GUARDRAIL (the governance control) ----
def is_safe(sql: str) -> bool:
    s = sql.strip().lower()
    if not s.startswith("select"):
        return False
    banned = ("insert", "update", "delete", "drop", "alter", "create", ";--", "attach")
    return not any(b in s for b in banned)

def load(con, table):
    rows = list(csv.DictReader(open(os.path.join(HERE, table + ".csv"))))
    cols = list(rows[0].keys())
    con.execute(f"CREATE TABLE {table} ({','.join(c + ' TEXT' for c in cols)})")
    con.executemany(f"INSERT INTO {table} VALUES ({','.join('?' * len(cols))})",
                    [[r[c] for c in cols] for r in rows])

def run(con, label, sql):
    print(f"\n=== {label} ===")
    if not is_safe(sql):
        print("  BLOCKED by guardrail: not a read-only SELECT.")
        return
    rows = con.execute(sql).fetchall()
    for r in rows:
        print("   " + " | ".join(str(c) for c in r))
    print(f"   ({len(rows)} break row(s))")

QUERIES = {
 "1 AMOUNT BREAK":
   """SELECT lend.loan_id,lend.lender,lend.par_amount,agt.par_amount FROM lender_positions lend
      JOIN agent_positions agt ON lend.loan_id=agt.loan_id AND lend.lender=agt.lender
      WHERE CAST(lend.par_amount AS INT)<>CAST(agt.par_amount AS INT)""",
 "2 MISSING IN AGENT":
   """SELECT lend.loan_id,lend.lender FROM lender_positions lend
      LEFT JOIN agent_positions agt ON lend.loan_id=agt.loan_id AND lend.lender=agt.lender WHERE agt.loan_id IS NULL""",
 "3 MISSING IN LENDER":
   """SELECT agt.loan_id,agt.lender FROM agent_positions agt
      LEFT JOIN lender_positions lend ON agt.loan_id=lend.loan_id AND agt.lender=lend.lender WHERE lend.loan_id IS NULL""",
 "4 DUPLICATE":
   """SELECT loan_id,lender,COUNT(*) FROM agent_positions GROUP BY loan_id,lender HAVING COUNT(*)>1""",
 "5 STALE DATE":
   """SELECT lend.loan_id,lend.lender,lend.as_of_date,agt.as_of_date FROM lender_positions lend
      JOIN agent_positions agt ON lend.loan_id=agt.loan_id AND lend.lender=agt.lender WHERE lend.as_of_date<>agt.as_of_date""",
 "6 CURRENCY MISMATCH":
   """SELECT lend.loan_id,lend.lender,lend.currency,agt.currency FROM lender_positions lend
      JOIN agent_positions agt ON lend.loan_id=agt.loan_id AND lend.lender=agt.lender WHERE lend.currency<>agt.currency""",
}

if __name__ == "__main__":
    con = sqlite3.connect(":memory:")
    load(con, "lender_positions"); load(con, "agent_positions")
    for label, sql in QUERIES.items():
        run(con, label, sql)
    # Guardrail proof: a write attempt is refused before it can run.
    print("\n=== GUARDRAIL PROOF ===")
    run(con, "Attempted: DROP TABLE lender_positions", "DROP TABLE lender_positions")
