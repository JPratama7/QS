//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import "modules/screens"
import "modules/ipc"

ShellRoot {
    id: root

    ScreenShells {}

    Ipc {}
}
