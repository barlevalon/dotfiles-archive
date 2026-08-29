import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "alon.next-event"

  readonly property string configDir: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"
  readonly property string pluginDir: configDir + "/omarchy/plugins/alon.next-event"
  property var eventData: null
  property string status: "loading"
  property string errorText: ""

  readonly property string label: {
    if (status === "setup") return "\uf133  setup"
    if (status === "error") return "\uf071  calendar"
    if (!eventData) return ""
    var title = String(eventData.title || "Untitled")
    if (title.length > 36) title = title.slice(0, 35) + "…"
    return (eventData.ongoing ? "now" : Qt.formatTime(new Date(eventData.start), "HH:mm")) + " · " + title
  }

  readonly property string details: {
    if (status === "setup") return "Add Fastmail and Outlook ICS URLs to ~/.config/omarchy/calendar-feeds"
    if (errorText !== "") return errorText
    if (!eventData) return "No more timed events today"
    var start = Qt.formatTime(new Date(eventData.start), "HH:mm")
    var end = Qt.formatTime(new Date(eventData.end), "HH:mm")
    return eventData.title + "\n" + start + "–" + end
      + (eventData.meetingUrl ? "\nClick to join" : "")
  }

  visible: label !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!fetchProcess.running && pluginDir !== "") fetchProcess.running = true
  }

  function applyResult(output) {
    try {
      var result = JSON.parse(String(output || "{}"))
      status = String(result.status || "error")
      errorText = String(result.error || "")
      if (status === "ok") eventData = result.event || null
    } catch (error) {
      status = "error"
      errorText = "Calendar response was invalid"
    }
  }

  Process {
    id: fetchProcess
    command: [root.pluginDir + "/next_event.py"]
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.status = "error"
        root.errorText = "Calendar refresh failed"
      }
    }

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyResult(text)
    }
  }

  Process {
    id: openProcess
  }

  Timer {
    interval: 300000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    labelVisible: true
    tooltipText: root.details
    onPressed: function(button) {
      if (button === Qt.LeftButton && root.eventData && root.eventData.meetingUrl && !openProcess.running) {
        openProcess.command = ["xdg-open", root.eventData.meetingUrl]
        openProcess.running = true
      } else {
        root.refresh()
      }
    }
  }
}
