pragma ComponentBehavior: Bound

import QtQuick
import "../network"
import "../vpn"

QtObject {
    id: root

    property VpnMenuHost vpnHost: VpnMenuHost {}
    property NetworkMenuHost networkHost: NetworkMenuHost {}
}
