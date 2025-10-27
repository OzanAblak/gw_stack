# \# GW Stack

# 

# Minimal gateway→planner→UI yığını.

# 

# \## Bileşenler

# \- \*\*gateway\*\*: Nginx proxy + statik UI (port \*\*18088\*\*)

# \- \*\*planner\*\*: Flask/Waitress API, TTL→410 mantığı (port \*\*19090\*\*)

# \- \*\*ui\*\*: Tek sayfa dashboard

# 

# \## Hızlı Başlangıç

# ```bash

# docker compose up -d



