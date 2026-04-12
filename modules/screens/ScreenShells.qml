import QtQuick
import Quickshell
import "../../services/ui"

Variants {
    model: ScreenRegistryService.enabledScreens

    delegate: ScreenShellDelegate {
        required property ShellScreen modelData
        context: ScreenRegistryService.createContext(modelData)
    }
}
