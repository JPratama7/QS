import QtQuick
import Quickshell
import "../../services/ui"

Variants {
    model: ScreenRegistry.enabledScreens

    delegate: ScreenShellDelegate {
        required property ShellScreen modelData
        context: ScreenRegistry.createContext(modelData)
    }
}
