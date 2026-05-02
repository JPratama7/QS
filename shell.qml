//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import "modules/ipc"
import "modules/screens"

ShellRoot {
    id: root

    ScreenShells {
    }

    Ipc {
    }

}
