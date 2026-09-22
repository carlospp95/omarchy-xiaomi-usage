import QtQuick
import Quickshell.Io

// Headless producer for the built-in agents panel. The panel discovers any
// *.json in ~/.local/state/omarchy/agents/usage/, so this plugin ships no UI:
// it just runs the Xiaomi collector on a cadence and lands the record where
// omarchy.agents already watches.
Item {
  id: root

  readonly property string pluginDir: {
    var dir = String(Qt.resolvedUrl("."))
    if (dir.indexOf("file://") === 0) dir = dir.substring(7)
    return dir.replace(/\/$/, "")
  }

  // The panel's open/refresh cycle only regenerates first-party collectors in
  // $OMARCHY_PATH/bin, so this record never gets the panel's --limits-only
  // kick: this timer is the sole refresher. A short cadence keeps the panel
  // close to live without hammering anything — the collector dedups both its
  // local scan and the Xiaomi probe on its own.
  property int refreshIntervalSec: 120

  function refresh() {
    if (root.pluginDir === "" || refreshProcess.running) return
    refreshProcess.command = ["bash", root.pluginDir + "/refresh.sh"]
    refreshProcess.running = true
  }

  Timer {
    interval: root.refreshIntervalSec * 1000
    running: root.pluginDir !== ""
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Process {
    id: refreshProcess
    running: false

    stdout: StdioCollector { waitForEnd: true }

    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (text.trim() !== "") console.warn("xiaomi.agent-usage", text.trim())
    }
  }
}
