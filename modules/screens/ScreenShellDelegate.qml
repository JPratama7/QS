pragma ComponentBehavior: Bound

import QtQuick
import "../../types"
import "../../services/ui"
import "../bar"
import "../popups"
import "../launcher"

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

        Loader {
            id: launcherLoader
            active: false

            sourceComponent: LauncherOverlayWindow {
                screenName: delegate.context.name
            }

            onLoaded: {
                item.visible = true
                item.reset()
            }

            Connections {
                target: ShellUI
                function onLauncherOpened(screenName: string): void {
                    if (screenName === delegate.context.name) {
                        launcherLoader.active = true
                    }
                }
                function onLauncherClosed(): void {
                    launcherLoader.active = false
                }
            }
        }
}
