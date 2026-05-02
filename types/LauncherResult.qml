import QtQuick

// Normalized result shape returned by any launcher provider.
// Providers fill all fields; consumers never inspect provider internals.
QtObject {
    // Display
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    // Provider identity — used by Launcher to dispatch activate()
    property string providerId: ""
    // Opaque payload the provider needs to execute the action
    property var data: null
}
