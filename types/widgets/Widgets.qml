pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "bar"

JsonObject {
    property Bar bar

    bar: Bar {
    }

}
