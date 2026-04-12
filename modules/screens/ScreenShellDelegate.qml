import QtQuick
import "../../types"
import "../bar"

Item {
    id: delegate

    required property ScreenContext context

    BarContentWindow {
        context: delegate.context
    }

    BarTriggerZone {
        context: delegate.context
    }
}
