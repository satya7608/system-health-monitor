import sys
import datetime

LOG_FILE = "alerts_python.log"

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.datetime.now()} : {msg}\n")

def analyze(msg):
    if "CRITICAL" in msg:
        return "HIGH PRIORITY"
    elif "WARNING" in msg:
        return "MEDIUM PRIORITY"
    else:
        return "LOW PRIORITY"

def main():
    if len(sys.argv) < 2:
        print("No alert message")
        return

    message = sys.argv[1]
    level = analyze(message)

    print(f"[Python Analyzer] {level}: {message}")
    log(f"{level}: {message}")

if __name__ == "__main__":
    main()
