import QtQuick 2.15  
import QtQuick.Layouts 1.15  
import QtQuick.Controls 2.15  
import Qt5Compat.GraphicalEffects   
import Quickshell  
import Quickshell.Hyprland  
import Quickshell.Io  
  
PanelWindow {  
    id: window 
    visible: false 
    implicitWidth: 240  
    implicitHeight: 360  
    color: "transparent"  
    anchors { right: true; top: true }  
  
    FileView {  
        id: themeFile  
        path: Qt.resolvedUrl("Theme.json")  
        watchChanges: true  
        onFileChanged: reload()  
        onAdapterUpdated: writeAdapter()  
  
        JsonAdapter {  
            id: theme  
            property JsonObject powerPanel: JsonObject {  
                property string background: "#1e1e2e"  
                property string logout: "#f38ba8"  
                property string reboot: "#9ece6a"  
                property string shutdown: "#f7768e"  
                property string suspend: "#7aa2f7"  
                property string cancel: "#a9b1d6"  
  
                property string logoutFont: "#ffffff"  
                property string rebootFont: "#000000"  
                property string shutdownFont: "#ffffff"  
                property string suspendFont: "#ffffff"  
                property string cancelFont: "#000000"  
  
                property string logoutIcon: "#ffffff"  
                property string rebootIcon: "#000000"  
                property string shutdownIcon: "#ffffff"  
                property string suspendIcon: "#ffffff"  
                property string cancelIcon: "#000000"  
            }  
        }  
    }  
  
    Rectangle {  
        anchors.fill: parent  
        anchors.margins: 8  
        radius: 16  
        color: theme.powerPanel.background  
  
        ColumnLayout {  
            anchors.centerIn: parent  
            spacing: 12  
  
            Repeater {  
                model: [  
                    { action: "exit", text: "Logout", color: theme.powerPanel.logout,   
                      fontColor: theme.powerPanel.logoutFont, iconColor: theme.powerPanel.logoutIcon },  
                    { action: "exec systemctl reboot", text: "Reboot", color: theme.powerPanel.reboot,  
                      fontColor: theme.powerPanel.rebootFont, iconColor: theme.powerPanel.rebootIcon },  
                    { action: "exec systemctl poweroff", text: "Shutdown", color: theme.powerPanel.shutdown,  
                      fontColor: theme.powerPanel.shutdownFont, iconColor: theme.powerPanel.shutdownIcon },  
                    { action: "exec systemctl suspend", text: "Suspend", color: theme.powerPanel.suspend,  
                      fontColor: theme.powerPanel.suspendFont, iconColor: theme.powerPanel.suspendIcon },  
                    { action: "", text: "Cancel", color: theme.powerPanel.cancel,  
                      fontColor: theme.powerPanel.cancelFont, iconColor: theme.powerPanel.cancelIcon }  
                ]  
  
                delegate: Rectangle {  
                    width: 180; height: 44; radius: 10  
                    color: modelData.color  
  
                    RowLayout {  
                        anchors.centerIn: parent  
                        spacing: 10  
  
                        Item {  
                            width: 20; height: 20  
                            Image {  
                                id: icon  
                                anchors.fill: parent  
                                source: "icons/circle.svg"  
                                visible: false  
                            }  
                            ColorOverlay {  
                                anchors.fill: parent  
                                source: icon  
                                color: modelData.iconColor  
                            }  
                        }  
  
                        Text {  
                            text: modelData.text  
                            color: modelData.fontColor  
                            font.pixelSize: 16  
                        }  
                    }  
  
                    MouseArea {  
                        anchors.fill: parent  
                        onClicked: {  
                            if (modelData.action === "") {  
                                window.visible = false  
                            } else {  
                                Hyprland.dispatch(modelData.action)  
                            }  
                        }  
                    }  
                }  
            }  
        }  
    }  
}