#!/usr/bin/python3

import json
import os
import re
import sys
import urllib.request
from datetime import date, datetime, time, timedelta
from html import unescape
from pathlib import Path
from urllib.parse import urlsplit

import recurring_ical_events
from icalendar import Calendar


CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "omarchy/calendar-feeds"
MAX_FEED_BYTES = 10 * 1024 * 1024
URL_PATTERN = re.compile(r"https?://[^\s<>\"']+", re.IGNORECASE)


def local_datetime(value):
    if isinstance(value, date) and not isinstance(value, datetime):
        return None
    if value.tzinfo is None:
        return value.astimezone()
    return value.astimezone()


def meeting_url(component):
    fields = ("CONFERENCE", "X-GOOGLE-CONFERENCE", "URL", "LOCATION", "DESCRIPTION")
    for field in fields:
        for match in URL_PATTERN.findall(unescape(str(component.get(field, "")))):
            url = match.rstrip(".,;:!?)]}")
            parsed = urlsplit(url)
            host = (parsed.hostname or "").lower().rstrip(".")
            if parsed.scheme != "https" or parsed.username or parsed.password:
                continue
            if host == "meet.google.com" or host in {
                "teams.microsoft.com",
                "teams.live.com",
                "teams.cloud.microsoft",
            } or host == "zoom.us" or host.endswith(".zoom.us"):
                return url
    return ""


def events_in_feed(data, day_start, day_end):
    calendar = Calendar.from_ical(data)
    for component in recurring_ical_events.of(calendar).between(day_start, day_end):
        if str(component.get("STATUS", "")).upper() == "CANCELLED":
            continue
        start = local_datetime(component.decoded("DTSTART"))
        if start is None:  # All-day entries are not useful in a next-meeting label.
            continue
        raw_end = component.decoded("DTEND") if component.get("DTEND") else start
        end = local_datetime(raw_end) or start
        yield {
            "title": " ".join(str(component.get("SUMMARY", "Untitled")).split())[:120],
            "start": start,
            "end": max(start, end),
            "meeting_url": meeting_url(component),
        }


def next_event(feeds, now):
    day_start = datetime.combine(now.date(), time.min, now.tzinfo)
    day_end = day_start + timedelta(days=1)
    events = []
    failures = 0

    for data in feeds:
        try:
            events.extend(events_in_feed(data, day_start, day_end))
        except Exception:
            failures += 1

    upcoming = [event for event in events if event["start"] >= now or event["end"] > now]
    upcoming.sort(key=lambda event: event["start"])
    event = upcoming[0] if upcoming else None
    if event:
        event = {
            "title": event["title"],
            "start": event["start"].isoformat(),
            "end": event["end"].isoformat(),
            "ongoing": event["start"] <= now < event["end"],
            "meetingUrl": event["meeting_url"],
        }
    return event, failures


def feed_urls():
    if not CONFIG.exists():
        return []
    urls = []
    for raw_line in CONFIG.read_text().splitlines():
        line = raw_line.strip()
        if line and not line.startswith("#"):
            if not line.startswith("https://"):
                raise ValueError("Calendar feeds must use HTTPS")
            urls.append(line)
    return urls


def fetch(url):
    request = urllib.request.Request(url, headers={"User-Agent": "omarchy-next-event/1.0"})
    with urllib.request.urlopen(request, timeout=10) as response:
        data = response.read(MAX_FEED_BYTES + 1)
    if len(data) > MAX_FEED_BYTES:
        raise ValueError("Calendar feed is too large")
    return data


def main():
    try:
        urls = feed_urls()
        if not urls:
            print(json.dumps({"status": "setup"}))
            return

        feeds = []
        failures = 0
        for url in urls:
            try:
                feeds.append(fetch(url))
            except Exception:
                failures += 1

        event, parse_failures = next_event(feeds, datetime.now().astimezone())
        failures += parse_failures
        if not feeds:
            print(json.dumps({"status": "error", "error": "Calendar feeds unavailable"}))
        else:
            error = f"{failures} calendar feed failed" if failures else ""
            print(json.dumps({"status": "ok", "event": event, "error": error}))
    except Exception as error:
        print(json.dumps({"status": "error", "error": str(error)}))


def self_test():
    sample = b"""BEGIN:VCALENDAR\r
VERSION:2.0\r
BEGIN:VEVENT\r
UID:recurring\r
DTSTART:20260829T150000Z\r
DTEND:20260829T153000Z\r
RRULE:FREQ=DAILY;COUNT=2\r
SUMMARY:Daily meeting\r
DESCRIPTION:Join https://meet.google.com/abc-defg-hij\r
END:VEVENT\r
BEGIN:VEVENT\r
UID:all-day\r
DTSTART;VALUE=DATE:20260829\r
SUMMARY:Ignore me\r
END:VEVENT\r
END:VCALENDAR\r
"""
    now = datetime.fromisoformat("2026-08-29T14:00:00+00:00")
    event, failures = next_event([sample], now)
    assert failures == 0
    assert event["title"] == "Daily meeting"
    assert datetime.fromisoformat(event["start"]).timestamp() == datetime.fromisoformat("2026-08-29T15:00:00+00:00").timestamp()
    assert event["meetingUrl"] == "https://meet.google.com/abc-defg-hij"

    malicious = Calendar.from_ical(b"""BEGIN:VCALENDAR\r
VERSION:2.0\r
BEGIN:VEVENT\r
UID:malicious\r
DTSTART:20260829T150000Z\r
DESCRIPTION:https://meet.google.com.evil.example/join\r
END:VEVENT\r
END:VCALENDAR\r
""").walk("VEVENT")[0]
    assert meeting_url(malicious) == ""
    print("ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        self_test()
    else:
        main()
