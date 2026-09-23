pragma ComponentBehavior: Bound

import QtQuick
import "../controlcenter"
import "../network"
import "../vpn"

QtObject {
    id: root

    property VpnMenuHost vpnHost: VpnMenuHost {}
    property NetworkMenuHost networkHost: NetworkMenuHost {}
    property ControlCenterHost controlCenterHost: ControlCenterHost {}
}
