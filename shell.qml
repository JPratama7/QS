//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import "config"
import "services/ui"
import "services/system"
import "modules/screens"

ShellRoot {
    id: root

    ScreenShells {}
}
