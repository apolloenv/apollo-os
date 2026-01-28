import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property bool vertical: false
    property bool borderless: Config.options.bar.borderless
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    
    readonly property int workspacesShown: Config.options.bar.workspaces.shown
    readonly property int workspaceGroup: Math.floor((monitor?.activeWorkspace?.id - 1) / root.workspacesShown)
    property list<bool> workspaceOccupied: []
    property int widgetPadding: 4
    property int workspaceButtonWidth: 26
    property real activeWorkspaceMargin: 2
    property real workspaceIconSize: workspaceButtonWidth * 0.69
    property real workspaceIconSizeShrinked: workspaceButtonWidth * 0.55
    property real workspaceIconOpacityShrinked: 1
    property real workspaceIconMarginShrinked: -4
    property int workspaceIndexInGroup: (monitor?.activeWorkspace?.id - 1) % root.workspacesShown

    property bool showNumbers: false  // Deaktiviert - keine Ziffern beim Super-Drücken
    // Timer und Connections für Super-Taste deaktiviert
    /*
    Timer {
        id: showNumbersTimer
        interval: (Config?.options.bar.autoHide.showWhenPressingSuper.delay ?? 100)
        repeat: false
        onTriggered: {
            root.showNumbers = true
        }
    }
    Connections {
        target: GlobalStates
        function onSuperDownChanged() {
            if (!Config?.options.bar.autoHide.showWhenPressingSuper.enable) return;
            if (GlobalStates.superDown) showNumbersTimer.restart();
            else {
                showNumbersTimer.stop();
                root.showNumbers = false;
            }
        }
        function onSuperReleaseMightTriggerChanged() { 
            showNumbersTimer.stop()
        }
    }
    */

    // Function to get active workspace IDs dynamically
    property var activeWorkspaceIds: []
    
    function updateActiveWorkspaces() {
        let workspaces = Hyprland.workspaces.values
            .filter(ws => ws.id > 0) // Only positive IDs (no special workspaces)
            .sort((a, b) => a.id - b.id) // Sort by ID
            .map(ws => ws.id);
        activeWorkspaceIds = workspaces;
    }

    // Occupied workspace updates
    Component.onCompleted: updateActiveWorkspaces()
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            updateActiveWorkspaces();
        }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            updateActiveWorkspaces();
        }
    }

    implicitWidth: root.vertical ? Appearance.sizes.verticalBarWidth : (root.workspaceButtonWidth * activeWorkspaceIds.length)
    implicitHeight: root.vertical ? (root.workspaceButtonWidth * activeWorkspaceIds.length) : Appearance.sizes.barHeight

    // Scroll to switch workspaces
    WheelHandler {
        onWheel: (event) => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch(`workspace r+1`);
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch(`workspace r-1`);
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        onPressed: (event) => {
            if (event.button === Qt.BackButton) {
                Hyprland.dispatch(`togglespecialworkspace`);
            } 
        }
    }

    // Workspaces - background (jetzt dynamisch nur für aktive)
    Grid {
        z: 1
        anchors.centerIn: parent

        rowSpacing: 0
        columnSpacing: 0
        columns: root.vertical ? 1 : activeWorkspaceIds.length
        rows: root.vertical ? activeWorkspaceIds.length : 1

        Repeater {
            model: activeWorkspaceIds.length

            Rectangle {
                z: 1
                implicitWidth: workspaceButtonWidth
                implicitHeight: workspaceButtonWidth
                radius: (width / 2)
                
                // Hintergrund komplett unsichtbar (kein grauer Hintergrund mehr)
                color: "transparent"
                opacity: 0
            }
        }
    }

    // Active workspace indicator - ENTFERNT, nur Punkte verwenden
    Rectangle {
        z: 2
        radius: Appearance.rounding.full
        color: "transparent"  // Unsichtbar
        opacity: 0  // Komplett deaktiviert

        anchors {
            verticalCenter: vertical ? undefined : parent.verticalCenter
            horizontalCenter: vertical ? parent.horizontalCenter : undefined
        }

        width: 0
        height: 0
    }

    // Workspaces - numbers/dots (dynamisch)
    Grid {
        z: 3

        columns: root.vertical ? 1 : activeWorkspaceIds.length
        rows: root.vertical ? activeWorkspaceIds.length : 1
        columnSpacing: 0
        rowSpacing: 0

        anchors.fill: parent

        Repeater {
            model: activeWorkspaceIds.length

            Button {
                id: button
                property int workspaceValue: activeWorkspaceIds[index]
                implicitHeight: vertical ? Appearance.sizes.verticalBarWidth : Appearance.sizes.barHeight
                implicitWidth: vertical ? Appearance.sizes.verticalBarWidth : Appearance.sizes.verticalBarWidth
                onPressed: Hyprland.dispatch(`workspace ${workspaceValue}`)
                width: vertical ? undefined : workspaceButtonWidth
                height: vertical ? workspaceButtonWidth : undefined

                background: Item {
                    id: workspaceButtonBackground
                    implicitWidth: workspaceButtonWidth
                    implicitHeight: workspaceButtonWidth
                    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(button.workspaceValue)
                    property var mainAppIconSource: Quickshell.iconPath(AppSearch.guessIcon(biggestWindow?.class), "image-missing")

                    StyledText { // Workspace number text
                        opacity: root.showNumbers
                            || ((Config.options?.bar.workspaces.alwaysShowNumbers && (!Config.options?.bar.workspaces.showAppIcons || !workspaceButtonBackground.biggestWindow || root.showNumbers))
                            || (root.showNumbers && !Config.options?.bar.workspaces.showAppIcons)
                            )  ? 1 : 0
                        z: 3

                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            pixelSize: Appearance.font.pixelSize.small - ((text.length - 1) * (text !== "10") * 2)
                            family: Config.options?.bar.workspaces.useNerdFont ? Appearance.font.family.iconNerd : defaultFont
                        }
                        text: Config.options?.bar.workspaces.numberMap[button.workspaceValue - 1] || button.workspaceValue
                        elide: Text.ElideRight
                        color: (monitor?.activeWorkspace?.id == button.workspaceValue) ? 
                            Appearance.m3colors.m3onPrimary : 
                            (workspaceOccupied[index] ? Appearance.m3colors.m3onSecondaryContainer : 
                                Appearance.colors.colOnLayer1Inactive)

                        Behavior on opacity {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                    }
                    Rectangle { // Dot - weißer Punkt mit variabler Transparenz
                        id: wsDot
                        visible: true
                        anchors.centerIn: parent
                        width: workspaceButtonWidth * 0.18
                        height: width
                        radius: width / 2
                        
                        // Immer weiß, aber unterschiedliche Opacity
                        color: "#FFFFFF"
                        
                        // Aktiver Workspace: 100% opacity, Inaktive: 50% opacity
                        opacity: (monitor?.activeWorkspace?.id == button.workspaceValue) ? 1.0 : 0.5

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    Item { // Main app icon
                        anchors.centerIn: parent
                        width: workspaceButtonWidth
                        height: workspaceButtonWidth
                        opacity: !Config.options?.bar.workspaces.showAppIcons ? 0 :
                            (workspaceButtonBackground.biggestWindow && !root.showNumbers && Config.options?.bar.workspaces.showAppIcons) ? 
                            1 : workspaceButtonBackground.biggestWindow ? workspaceIconOpacityShrinked : 0
                            visible: opacity > 0
                        IconImage {
                            id: mainAppIcon
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.bottomMargin: (!root.showNumbers && Config.options?.bar.workspaces.showAppIcons) ? 
                                (workspaceButtonWidth - workspaceIconSize) / 2 : workspaceIconMarginShrinked
                            anchors.rightMargin: (!root.showNumbers && Config.options?.bar.workspaces.showAppIcons) ? 
                                (workspaceButtonWidth - workspaceIconSize) / 2 : workspaceIconMarginShrinked

                            source: workspaceButtonBackground.mainAppIconSource
                            implicitSize: (!root.showNumbers && Config.options?.bar.workspaces.showAppIcons) ? workspaceIconSize : workspaceIconSizeShrinked

                            Behavior on opacity {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                            Behavior on anchors.bottomMargin {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                            Behavior on anchors.rightMargin {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                            Behavior on implicitSize {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                        }

                        Loader {
                            active: Config.options.bar.workspaces.monochromeIcons
                            anchors.fill: mainAppIcon
                            sourceComponent: Item {
                                Desaturate {
                                    id: desaturatedIcon
                                    visible: false // There's already color overlay
                                    anchors.fill: parent
                                    source: mainAppIcon
                                    desaturation: 0.8
                                }
                                ColorOverlay {
                                    anchors.fill: desaturatedIcon
                                    source: desaturatedIcon
                                    color: ColorUtils.transparentize(wsDot.color, 0.9)
                                }
                            }
                        }
                    }
                }
                

            }

        }

    }

}
