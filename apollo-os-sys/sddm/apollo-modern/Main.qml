import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    
    property string defaultBackground: "wallpaper.jpg"
    
    // Background image with blur
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background || defaultBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 40
        }
    }
    
    // Dark overlay for readability
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }
    
    // Main content container
    Item {
        anchors.fill: parent
        
        // Clock - top center, large
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.15
            spacing: 5
            
            Text {
                id: timeLabel
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 72
                font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                font.weight: Font.Light
                color: "#ffffff"
                
                function updateTime() {
                    text = Qt.formatTime(new Date(), "HH:mm")
                }
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: timeLabel.updateTime()
                }
                
                Component.onCompleted: updateTime()
            }
            
            Text {
                id: dateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 18
                font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                color: "#cccccc"
                
                function updateDate() {
                    var locale = Qt.locale("de_DE")
                    text = new Date().toLocaleDateString(locale, Locale.LongFormat)
                }
                
                Component.onCompleted: updateDate()
                
                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: dateLabel.updateDate()
                }
            }
        }
        
        // Login form - center
        Column {
            anchors.centerIn: parent
            spacing: 20
            width: 320
            
            // User icon
            Rectangle {
                width: 100
                height: 100
                radius: 50
                color: "#ffffff22"
                border.color: "#ffffff44"
                border.width: 2
                anchors.horizontalCenter: parent.horizontalCenter
                
                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "Font Awesome 6 Free, Noto Sans Symbols2"
                    font.pointSize: 40
                    color: "#ffffff"
                }
            }
            
            // Username
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: userModel.lastUser || "User"
                font.pointSize: 20
                font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                color: "#ffffff"
            }
            
            // Password field
            Rectangle {
                width: parent.width
                height: 50
                radius: 25
                color: "#ffffff22"
                border.color: passwordField.focus ? "#ffffff88" : "#ffffff44"
                border.width: 2
                
                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }
                
                TextField {
                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 5
                    horizontalAlignment: TextInput.AlignHCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    font.pointSize: 14
                    font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                    color: "#ffffff"
                    placeholderText: "Passwort eingeben"
                    placeholderTextColor: "#888888"
                    
                    background: Rectangle {
                        color: "transparent"
                    }
                    
                    onAccepted: {
                        sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
                    }
                    
                    Keys.onEscapePressed: {
                        passwordField.text = ""
                    }
                }
            }
            
            // Error message
            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                color: "#ff6b6b"
                visible: text !== ""
                
                Connections {
                    target: sddm
                    function onLoginFailed() {
                        errorMessage.text = "Falsches Passwort"
                        passwordField.text = ""
                        passwordField.focus = true
                        errorTimer.start()
                    }
                    function onLoginSucceeded() {
                        errorMessage.text = ""
                    }
                }
                
                Timer {
                    id: errorTimer
                    interval: 3000
                    onTriggered: errorMessage.text = ""
                }
            }
        }
        
        // Bottom bar - session and power
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 40
            spacing: 30
            
            // Session selector
            ComboBox {
                id: sessionSelector
                width: 180
                height: 40
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                
                background: Rectangle {
                    color: "#ffffff15"
                    radius: 20
                    border.color: "#ffffff33"
                    border.width: 1
                }
                
                contentItem: Text {
                    leftPadding: 15
                    text: sessionSelector.displayText
                    font.pointSize: 12
                    font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                    color: "#cccccc"
                    verticalAlignment: Text.AlignVCenter
                }
                
                popup: Popup {
                    y: sessionSelector.height
                    width: sessionSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 5
                    
                    background: Rectangle {
                        color: "#2a2a3e"
                        radius: 10
                        border.color: "#ffffff22"
                    }
                    
                    contentItem: ListView {
                        implicitHeight: contentHeight
                        model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                        clip: true
                    }
                }
                
                delegate: ItemDelegate {
                    width: sessionSelector.width
                    contentItem: Text {
                        text: name
                        color: "#ffffff"
                        font.pointSize: 12
                        font.family: "Google Sans Flex Medium, Cantarell, sans-serif"
                    }
                    background: Rectangle {
                        color: highlighted ? "#ffffff22" : "transparent"
                        radius: 5
                    }
                }
            }
            
            // Power buttons
            Row {
                spacing: 15
                
                // Reboot
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: mouseAreaReboot.containsMouse ? "#ffffff33" : "#ffffff15"
                    border.color: "#ffffff33"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: "Font Awesome 6 Free, Noto Sans Symbols2"
                        font.pointSize: 14
                        color: "#cccccc"
                    }
                    
                    MouseArea {
                        id: mouseAreaReboot
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sddm.reboot()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                
                // Shutdown
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: mouseAreaShutdown.containsMouse ? "#ffffff33" : "#ffffff15"
                    border.color: "#ffffff33"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: "Font Awesome 6 Free, Noto Sans Symbols2"
                        font.pointSize: 14
                        color: "#cccccc"
                    }
                    
                    MouseArea {
                        id: mouseAreaShutdown
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sddm.powerOff()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
