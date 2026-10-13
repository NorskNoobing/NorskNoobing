import json
import os
from pathlib import Path
from urllib.request import Request, urlopen


request = Request(
    "https://api.todoist.com/api/v1/tasks/completed/stats",
    headers={"Authorization": f"Bearer {os.environ['TODOIST_API_KEY']}"},
)

with urlopen(request, timeout=30) as response:
    stats = json.load(response)

lines = [
    f"🏆  {stats['karma']:,.0f} Karma Points",
    f"🌸  Completed {stats['days_items'][0]['total_completed']} tasks today",
    f"✅  Completed {stats['completed_count']:,} tasks so far",
    f"⏳  Longest streak is {stats['goals']['max_daily_streak']['count']} days",
]

path = Path("README.md")
readme = path.read_text(encoding="utf-8")
start = "<!-- TODO-IST:START -->"
end = "<!-- TODO-IST:END -->"

if readme.count(start) != 1 or readme.count(end) != 1:
    raise ValueError("README must contain exactly one pair of Todoist markers")

before, remaining = readme.split(start, 1)
old_stats, after = remaining.split(end, 1)
updated = before + start + "\n" + "           \n".join(lines) + "\n" + end + after

if updated != readme:
    path.write_text(updated, encoding="utf-8")
    print("Updated Todoist stats")
else:
    print("Todoist stats unchanged")
