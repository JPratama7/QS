import "../../services/ui"
import QtQuick
import Quickshell

Variants {
    model: ScreenRegistry.enabledScreens

    delegate: ScreenShellDelegate {
        required property ShellScreen modelData

        context: ScreenRegistry.createContext(modelData)
    }

}
