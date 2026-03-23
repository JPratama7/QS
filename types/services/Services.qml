pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

JsonObject {
    property JsonObject audio
    property JsonObject brightness

    audio: Audio {
    }

    brightness: Brightness {
    }

}
