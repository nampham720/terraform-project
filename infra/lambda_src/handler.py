import json, os, time, uuid, boto3
s3 = boto3.client("s3")
BUCKET = os.environ["S3_BUCKET"]
def handler(event, context):
    try:
        body = event.get("body")
        if event.get("isBase64Encoded"):
            import base64
            body = base64.b64decode(body).decode("utf-8")
        data = json.loads(body or "{}")
        record = {
            "chat_id": data.get("chat_id") or str(uuid.uuid4()),
            "sender": data.get("sender") or "unknown",
            "message": data.get("message") or "",
            "ts": data.get("ts") or time.time(),
        }
        key = f"raw/year={time.gmtime().tm_year}/month={time.gmtime().tm_mon}/chat={record['chat_id']}/{uuid.uuid4()}.json"
        s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps(record).encode("utf-8"))
        return {"statusCode": 200, "body": json.dumps({"ok": True, "s3_key": key})}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"ok": False, "error": str(e)})}

