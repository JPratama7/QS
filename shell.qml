//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import "config"
import "services/ui"
import "modules/screens"

ShellRoot {
    id: root

    ScreenShells {}
}
