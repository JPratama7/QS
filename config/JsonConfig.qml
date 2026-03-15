pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Default Layout Configuration
    property var layout: ({
        left: ["workspaces", "windowTitle"],
        right: [
            "systemMonitor",
            "network",
            "bluetooth",
            "battery",
            "audio",
            "brightness",
            "nightShift",
            "caffeine",
            "clock"
        ]
    })

    // Default Widget Configurations
    property var widgets: ({})

    // Status flag
    property bool isLoaded: false

    // Fetch config for a specific widget, merging with default fallback values
    function getWidgetConfig(widgetName, defaultValues) {
        var config = root.widgets[widgetName] || {};
        var result = Object.assign({}, defaultValues);
        for (var key in config) {
            result[key] = config[key];
        }
        return result;
    }

    // Read and parse the external JSON config using Quickshell's Process and SplitParser
    Process {
        id: configReader
        // Use jq to compress the JSON to a single line so SplitParser gets it in one chunk
        command: ["jq", "-c", ".", Quickshell.env("PWD") + "/config/user_config.json"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                if (!data || data.trim() === "") return;

                try {
                    var json = JSON.parse(data);

                    if (json.layout) {
                        root.layout = json.layout;
                    }

                    if (json.widgets) {
                        root.widgets = json.widgets;
                    }

                    root.isLoaded = true;
                    console.log("Loaded user_config.json successfully");
                } catch (error) {
                    console.log("Failed to parse user_config.json: " + error);
                }
            }
        }
    }
}
