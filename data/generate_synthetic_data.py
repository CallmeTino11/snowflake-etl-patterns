"""Generate small synthetic CSV files for the demo. No real or client data is used."""
import csv, random, sys, pathlib
from datetime import datetime, timedelta

out = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".")
random.seed(42)
regions = ["Gauteng", "Western Cape", "KwaZulu-Natal", "Eastern Cape"]
n_customers, n_invoices = 200, 5000

with open(out / "stg_customer.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["customer_code", "customer_name", "region", "loaded_at"])
    for i in range(1, n_customers + 1):
        w.writerow([f"C{i:04d}", f"Demo Customer {i}", random.choice(regions), "2026-01-01 00:00:00"])

start = datetime(2026, 1, 1)
with open(out / "stg_invoice.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["invoice_id", "customer_code", "amount", "invoice_ts", "loaded_at"])
    for i in range(1, n_invoices + 1):
        # several invoices share the same timestamp on purpose (see 01-watermark-batching)
        ts = start + timedelta(minutes=(i // 3))
        w.writerow([i, f"C{random.randint(1, n_customers):04d}", round(random.uniform(50, 5000), 2),
                    ts.strftime("%Y-%m-%d %H:%M:%S"), "2026-02-01 00:00:00"])
print("written:", out / "stg_customer.csv", out / "stg_invoice.csv")
