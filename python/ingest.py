import requests
import uuid
import random
import time
import json
#https://<api_id>.execute-api.<region>.amazonaws.com/ingest"
API_ENDPOINT = "https://lf78g3k9ae.execute-api.eu-north-1.amazonaws.com/ingest"


MESSAGES = [
    "Hello world",
    "Random text oaisjfoiasfjoiasjf",
    "Demo message",
    "Another test"
]

def generate_message():
    
    msg = {
        "text_id": str(uuid.uuid4()),
        "message": "Hello world"
    }
    return msg

def main():
    sent_messages = []
    for _ in range(3):
        msg = generate_message()
        print("Sending:", msg)   # <-- ensures you see the message
        sent_messages.append(msg)
        try:
            resp = requests.post(API_ENDPOINT, json=msg)
            print("Success:", resp.json())
        except Exception as e:
            print("Failed:", e)


    print("\nCurrent raw messages (JSON):")
    for m in sent_messages:
        print(m)

if __name__ == "__main__":
    main()

