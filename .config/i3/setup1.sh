#!/bin/bash
# i3 Workspace Startup Script
# Verified WM_CLASS:
#   Alacritty  → "Alacritty"
#   Yandex     → "Yandex-browser"
#   Telegram   → "TelegramDesktop"
#   v2rayN     → "v2rayN"

TERM_CLASS="Alacritty"
TERM_BIN="alacritty"

count_class() { xdotool search --class "$1" 2>/dev/null | wc -l; }
latest_of_class() { xdotool search --class "$1" 2>/dev/null | tail -1; }

# Launch app on a specific workspace:
# 1. switch to workspace
# 2. snapshot count
# 3. exec
# 4. wait for new window
# 5. force-move it to the workspace (catches slow starters)
# 6. switch again and focus it
launch_on_ws() {
    local ws="$1"
    local class="$2"
    local cmd="$3"

    i3-msg "workspace $ws"; sleep 0.4

    local before
    before=$(count_class "$class")

    i3-msg "exec --no-startup-id $cmd"

    local timeout=30 i=0
    until [ "$(count_class "$class")" -gt "$before" ]; do
        sleep 0.5; i=$((i+1))
        [ $i -ge $((timeout*2)) ] && echo "Timeout: $class" >&2 && return 1
    done
    sleep 0.3

    local win_id
    win_id=$(latest_of_class "$class")

    # Force the window onto the correct workspace and focus it
    i3-msg "[id=$win_id] move to workspace $ws"
    sleep 0.2
    i3-msg "workspace $ws"; sleep 0.3
    i3-msg "[id=$win_id] focus"
}

# ── WS 1 : Alacritty fullscreen ──────────────────────────────────────────────

launch_on_ws 1 "$TERM_CLASS" "$TERM_BIN"
i3-msg "fullscreen enable"

# ── WS 2 : Yandex Browser ────────────────────────────────────────────────────

launch_on_ws 2 "Yandex-browser" "yandex-browser"

# ── WS 3 : Telegram ──────────────────────────────────────────────────────────

launch_on_ws 3 "TelegramDesktop" "flatpak run org.telegram.desktop"

# ── WS 4 : 3 terminals  left | right-top / right-bottom ──────────────────────

i3-msg "workspace 4"; sleep 0.4

# Term 1 — left
BEFORE=$(count_class "$TERM_CLASS")
i3-msg "exec --no-startup-id $TERM_BIN"
until [ "$(count_class "$TERM_CLASS")" -gt "$BEFORE" ]; do sleep 0.5; done
sleep 0.3
TERM1=$(latest_of_class "$TERM_CLASS")
i3-msg "[id=$TERM1] move to workspace 4"
sleep 0.2
i3-msg "workspace 4"; sleep 0.3
i3-msg "[id=$TERM1] focus"

# Term 2 — right
i3-msg "split h"; sleep 0.2
BEFORE=$(count_class "$TERM_CLASS")
i3-msg "exec --no-startup-id $TERM_BIN"
until [ "$(count_class "$TERM_CLASS")" -gt "$BEFORE" ]; do sleep 0.5; done
sleep 0.3
TERM2=$(latest_of_class "$TERM_CLASS")
i3-msg "[id=$TERM2] move to workspace 4"
sleep 0.2
i3-msg "workspace 4"; sleep 0.3
i3-msg "[id=$TERM2] focus"

# Term 3 — below term 2
i3-msg "[id=$TERM2] focus"
i3-msg "split v"; sleep 0.2
BEFORE=$(count_class "$TERM_CLASS")
i3-msg "exec --no-startup-id $TERM_BIN"
until [ "$(count_class "$TERM_CLASS")" -gt "$BEFORE" ]; do sleep 0.5; done
sleep 0.3
TERM3=$(latest_of_class "$TERM_CLASS")
i3-msg "[id=$TERM3] move to workspace 4"
sleep 0.2
i3-msg "workspace 4"; sleep 0.3

# Focus term 1
i3-msg "[id=$TERM1] focus"

# ── WS 5 : Google Tasks (Yandex web app) ─────────────────────────────────────

launch_on_ws 5 "crx_okhfeehhillipaleckndoboggdkcebmo" "yandex-browser --app-id=okhfeehhillipaleckndoboggdkcebmo"

# ── WS 9 : v2rayN ────────────────────────────────────────────────────────────

launch_on_ws 9 "v2rayN" "/opt/v2rayN/v2rayN"

# ── Return to WS 1 ───────────────────────────────────────────────────────────

i3-msg "workspace 1"
echo "Startup complete."
