//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import Quickshell
import "modules/ipc"
import "modules/popups/shared"
import "modules/screens"

ShellRoot {
    id: root

    ScreenShells {
    }

    Ipc {
    }

    PopupHosts {
    }

}
