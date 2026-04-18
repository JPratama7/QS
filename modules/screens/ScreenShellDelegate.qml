import QtQuick
import "../../types"
import "../bar"
import "../popups"

Item {
    id: delegate

    required property ScreenContext context

    BarContentWindow {
        id: barWindow
        context: delegate.context
    }

    BarTriggerZone {
        context: delegate.context
    }

    PopupMenuWindow {
        context: delegate.context
        barWindow: barWindow
    }
}
