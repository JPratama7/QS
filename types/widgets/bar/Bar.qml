import QtQuick
import Quickshell.Io

JsonObject {
    property JsonObject config
    property JsonObject caffeine
    property JsonObject nightShift

    config: Config {}
    caffeine: Caffeine {}
    nightShift: NightShift {}
}
