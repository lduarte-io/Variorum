# VX-336 U7 window kit — L4's DROPPED CALL. Used as the scratch config's command (python3 -I
# drop-relay.py) in place of tee-shim.sh: it runs the product's shim, relays both directions
# verbatim and tees them (the same -in/-out.jsonl files), EXCEPT that the server's answer to
# the FIRST tools/call of `create_note` is written to the tee and NEVER forwarded to the client.
# The act lands in the store; the client never hears it. A file <tee>.HELD says when, so the
# runner kills the client turn then (the session is lost mid-call, as a dropped connection is).
import json, os, subprocess, sys, threading, time

tee, shim = os.environ["U7_TEE"], os.environ["U7_SHIM"]
child = subprocess.Popen([shim], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
held, lock = set(), threading.Lock()
log_in, log_out = open(tee + "-in.jsonl", "ab"), open(tee + "-out.jsonl", "ab")

def up():
    for line in iter(sys.stdin.buffer.readline, b""):
        log_in.write(line); log_in.flush()
        try:
            message = json.loads(line)
            if (message.get("method") == "tools/call" and message.get("params", {}).get("name") == "create_note"
                    and not held):
                with lock: held.add(message.get("id"))
        except Exception:
            pass
        child.stdin.write(line); child.stdin.flush()
    child.stdin.close()

threading.Thread(target=up, daemon=True).start()
for line in iter(child.stdout.readline, b""):
    log_out.write(line); log_out.flush()
    try:
        message = json.loads(line)
        with lock: hold = "id" in message and message.get("id") in held and "method" not in message
    except Exception:
        hold = False
    if hold:
        with open(tee + ".HELD", "w") as marker:
            marker.write(f"held the answer to request id {message.get('id')} at {time.strftime('%H:%M:%S')}\n")
        continue
    sys.stdout.buffer.write(line); sys.stdout.buffer.flush()
