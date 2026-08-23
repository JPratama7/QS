pragma ComponentBehavior: Bound

import QtQuick
import "../network"
import "../vpn"

QtObject {
    id: root

    VpnMenuHost {
    }

    NetworkMenuHost {
    }
}
