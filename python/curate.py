import boto3
import csv
import io
import psycopg2
import json

S3_BUCKET = "<Your bucket name>"
STAGED_PREFIX = "staged/"
CURATED_PREFIX = "curated/"

SECRET_ARN = "<Secret ARN after applied Terraform>"
REGION = "<Region>"

s3 = boto3.client("s3")
sm = boto3.client("secretsmanager", region_name=REGION)

conn = psycopg2.connect(
    host="<your host>",
    port=5432,
    dbname="<your db>", 
    user="<username>", 
    password="<secret password>"
)
print("Connected")
cur = conn.cursor()
cur.execute("""
CREATE TABLE IF NOT EXISTS chat_messages (
    chat_id VARCHAR(36) PRIMARY KEY,
    content TEXT,
    word_count INT
);            
""")
conn.commit()

def list_staged_files():
    resp = s3.list_objects_v2(Bucket=S3_BUCKET, Prefix=STAGED_PREFIX)
    return [obj["Key"] for obj in resp.get("Contents", [])]

def read_staged_csv(key):
    resp = s3.get_object(Bucket=S3_BUCKET, Key=key)
    csv_text = resp["Body"].read().decode().splitlines()
    reader = csv.DictReader(csv_text)
    return list(reader)

def write_curated_csv(rows, filename="curated_table.csv"):
    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=["chat_id", "content", "word_count"])
    writer.writeheader()
    writer.writerows(rows)
    s3.put_object(Bucket=S3_BUCKET, Key=f"{CURATED_PREFIX}{filename}", Body=buffer.getvalue())
    print(f"Written {filename} to {CURATED_PREFIX}")

def main():
    files = list_staged_files()
    if not files:
        print("No staged files found.")
        return

    all_rows = []
    for f in files:
        rows = read_staged_csv(f)
        for r in rows:
            print("This is row: ", r)
            r["word_count"] = len(r["content"].split())
            all_rows.append(r)
            # Insert/update Postgres
            cur.execute(
                """
                INSERT INTO chat_messages (chat_id, content, word_count)
                VALUES (%s, %s, %s)
                ON CONFLICT (chat_id) DO UPDATE
                SET content = EXCLUDED.content,
                    word_count = EXCLUDED.word_count
                """,
                (r["chat_id"], r["content"], r["word_count"])
            )
    conn.commit()

    write_curated_csv(all_rows)

    # Query Postgres table
    print("SELECT * FROM chat_messages")
    cur.execute("SELECT * FROM chat_messages;")
    rows = cur.fetchall()
    print("\nPostgres chat_messages table:")
    for r in rows:
        print(r)

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
