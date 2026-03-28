pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

JsonObject {
    property Config config
    property Caffeine caffeine
    property NightShift nightShift

    config: Config {}
    caffeine: Caffeine {}
    nightShift: NightShift {}
}
