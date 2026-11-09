"""Shows why a row-capped, watermark-based loader can skip rows (case 01).
Uses only the standard library (SQLite), so no Snowflake account is needed."""
import sqlite3

CAP = 1000

def build():
    con = sqlite3.connect(":memory:")
    con.execute("CREATE TABLE stg (invoice_id INTEGER, ts INTEGER)")
    con.execute("CREATE TABLE fact (invoice_id INTEGER, ts INTEGER)")
    # three invoices share every timestamp, so a cap of 1000 cuts through a tie
    con.executemany("INSERT INTO stg VALUES (?, ?)", [(i, i // 3) for i in range(5000)])
    return con

def capped(con):
    wm = -1
    while True:
        rows = con.execute("SELECT invoice_id, ts FROM stg WHERE ts > ? ORDER BY ts, invoice_id LIMIT ?",
                           (wm, CAP)).fetchall()
        if not rows:
            return
        con.executemany("INSERT INTO fact VALUES (?, ?)", rows)
        wm = max(r[1] for r in rows)

def full_window(con):
    upper = con.execute("SELECT MAX(ts) FROM stg").fetchone()[0]
    con.execute("INSERT INTO fact SELECT invoice_id, ts FROM stg WHERE ts > -1 AND ts <= ?", (upper,))

for name, loader in (("capped", capped), ("full window", full_window)):
    con = build()
    loader(con)
    staged = con.execute("SELECT COUNT(*) FROM stg").fetchone()[0]
    loaded = con.execute("SELECT COUNT(*) FROM fact").fetchone()[0]
    print(f"{name:12s} staged={staged} loaded={loaded} missing={staged - loaded}")
    if name == "full window":
        assert staged == loaded, "full-window loader must load every row"
    else:
        assert staged > loaded, "expected the capped loader to skip tied rows"
print("OK")
