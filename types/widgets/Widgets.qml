pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "bar"

JsonObject {
    property JsonObject bar

    bar: Bar {
    }

}
