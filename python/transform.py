import boto3
import json
import csv
import io

S3_BUCKET = "<S3_BUCKET_NAME>"
RAW_PREFIX = "raw/"
STAGED_PREFIX = "staged/"

s3 = boto3.client("s3")

def list_raw_files():
    resp = s3.list_objects_v2(Bucket=S3_BUCKET, Prefix=RAW_PREFIX)
    keys = [obj["Key"] for obj in resp.get("Contents", [])]
    # Remove the folder prefix itself
    return [k for k in keys if not k.endswith("/")]


def read_json(key):
    resp = s3.get_object(Bucket=S3_BUCKET, Key=key)
    body_str = resp["Body"].read().decode("utf-8")  # read once
    data = json.loads(body_str)
    print(f"Read {key}: {data}")
    return data

def write_staged_csv(rows, filename="staged_table.csv"):
    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=["chat_id", "content"])
    writer.writeheader()
    writer.writerows(rows)
    s3.put_object(Bucket=S3_BUCKET, Key=f"{STAGED_PREFIX}{filename}", Body=buffer.getvalue())
    print(f"Written {filename} to {STAGED_PREFIX}")

def main():
    files = list_raw_files()
    print(files)
    if not files:
        print("No raw files found.")
        return

    rows = []
    for key in list_raw_files():
        r = read_json(key)
        if r is None or not r.get("message", "").strip():
            print(f"Skipping empty message in {key}")
            continue
        # map message -> content
        rows.append({"chat_id": r["chat_id"], "content": r["message"]})

    write_staged_csv(rows)

    print("\nStaged Table:")
    print("chat_id | content")
    for r in rows:
        print(f"{r['chat_id']} | {r['content']}")

if __name__ == "__main__":
    main()
