from watchfiles import watch
import subprocess
from datetime import datetime

print("watching src update (*.fnl only) ...")

for changes in watch("src"):
    for action, path in changes:
        if path.endswith(".fnl"):
            print(f"[{datetime.now()}] {path} updated. Auto run make.")
            subprocess.run(["make"])