//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Io
import Qt5Compat.GraphicalEffects 



PanelWindow {
    id: panel
    anchors { top: true; right: true; left: true }
    implicitHeight: 40
    color: "transparent"
    margins { left: 10; right: 10; top: 5; bottom: 5 }
    
    FileView {
    id: themeFile
    path: Qt.resolvedUrl("Theme.json")
    watchChanges: true
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

        JsonAdapter {
        id: theme

            property JsonObject colors: JsonObject {
            property string primary: "#19232F"
            property string secondary: "#89b4fa"
            property string tertiary: "white"
            property string batterySaver:"white"
            property string power:"white"
            property string clock:"white"
            property string temp:"white"
            property string battery:"white"
            property string cpu:"white"
            property string ram:"white"
            property string volume:"white"
            property string performance:"white"
            property string balance:"white"
            property string fullscreen:"white"
            property string tray:"white"




    }

    property JsonObject icon: JsonObject {
        property string power:"white"
        property string clock:"white"
        property string temp:"white"
        property string battery:"white"
        property string cpu:"white"
        property string ram:"white"
        property string volume:"white"
        property string performance:"white"
        property string balance:"white"




    }

    property JsonObject font: JsonObject {
      property string primaryFont: "white"
      property string secondaryFont: "white"
      property string ram: "black"
      property string cpu: "black"
      property string battery: "black"
      property string temp: "black"
      property string clock: "black"
    }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    RowLayout {
        width: parent.width
        height: parent.height
        spacing: 5

        Rectangle {
            color:theme.colors.tertiary
            height: 40
            width: Math.min(Math.max(workspaceRow.implicitWidth + 16,40), parent.width / 5)
            radius: 15

            Row {
                anchors.centerIn: parent
                spacing: 8
                id: workspaceRow

                Repeater {
                    model: Hyprland.workspaces

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: {
                            if (modelData.focused) return theme.colors.secondary
                            if (modelData.active) return theme.colors.primary
                            return theme.colors.primary
                        }
                        border.color: modelData.hasFullscreen ? theme.colors.fullscreen : "transparent"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name || modelData.id
                            color: modelData.focused ? theme.font.primaryFont : theme.font.secondaryFont
                            font.bold: modelData.focused
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.activate()
                        }
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }
        Item { Layout.fillWidth: true }

        Rectangle {
            color:theme.colors.secondary
            //anchors.centerIn:parent
            //anchors.horizontalCenterOffset:-100
            height: 35
            width:475
            radius: 4

            Text{
                anchors.centerIn:parent
                text:"Wha u lookin at? is it really needed for each Tab to be functional?!"
                font.bold:true
                font.pixelSize:14
                color:theme.font.primaryFont
            }
        }

        Item { Layout.fillWidth: true }

        //volume
        Rectangle {
            color: theme.colors.volume
            height: 35
            width: 35
            radius: 14
            ColorOverlay{
                anchors.centerIn:parent
                height:20
                width:20
                source:Image{
                    source:"icons/volume.svg"
                }
                color:theme.icon.volume
            }

            MouseArea{
                anchors.fill:parent
                onClicked: Hyprland.dispatch("exec pavucontrol")
            }

        }

        Rectangle {  
            id: powerProfileBlock  
            height: 35  
            width: 35  // Made square since no text  
            radius: 15  
      
            // Dynamic background color based on power profile  
            color: {  
            switch (PowerProfiles.profile) {  
            case PowerProfile.PowerSaver: return theme.colors.batterySaver    // Green for power saver  
            case PowerProfile.Balanced: return theme.colors.balance      // Orange for balanced  
            case PowerProfile.Performance: return theme.colors.performance   // Red for performance  
            default: return "#9E9E9E"                         // Gray for unknown  
            }  
            }  
      
            // Smooth color transitions  
            Behavior on color {  
            ColorAnimation { duration: 200 }  
            }  
      
            MouseArea {
            anchors.fill: parent
            onClicked: {
            // Cycle: PowerSaver → Balanced → Performance → PowerSaver
            if (PowerProfiles.profile === PowerProfile.PowerSaver) {
                PowerProfiles.profile = PowerProfile.Balanced
            } else if (PowerProfiles.profile === PowerProfile.Balanced) {
                PowerProfiles.profile = PowerProfiles.hasPerformanceProfile
                ? PowerProfile.Performance
                : PowerProfile.PowerSaver
            } else {
                PowerProfiles.profile = PowerProfile.PowerSaver
            }
            }
            }

            ColorOverlay{
            anchors.centerIn: parent
            height:20
            width:20  
            source:Image {  
              
                // Dynamic icon based on power profile  
                source: {  
                    switch (PowerProfiles.profile) {  
                        case PowerProfile.PowerSaver: return "icons/saver.svg"  
                        case PowerProfile.Balanced: return "icons/balance.svg"  
                        case PowerProfile.Performance: return "icons/performance.svg"  
                        default: return "icons/power.svg"  
                    }  
                }  
        
            }
            color:theme.icon.performance
            }  
        }


        // RAM Block
        Rectangle {
            id: ramBlock
            height: 35
            width: 80
            radius: 15
            color: theme.colors.ram

            property real ramUsagePercent: 0
            property string ramUsageText: "0%"

            Process {
                id: ramProcess
                command: ["sh", "-c", "free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'"]
                running: true

                onRunningChanged: {
                    if (!running) restartTimer.start()
                }

                stdout: SplitParser {
                    onRead: data => {
                        let usage = parseFloat(data.trim())
                        if (!isNaN(usage)) {
                            ramBlock.ramUsagePercent = usage
                            ramBlock.ramUsageText = Math.round(usage) + "%"
                        }
                    }
                }
            }

            Timer {
                id: restartTimer
                interval: 2000
                onTriggered: ramProcess.running = true
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                ColorOverlay{
                height: 20
                width: 20 
                    source:Image { source: "icons/ram.svg"; }
                color:theme.icon.ram
                }
                Text {
                    text: ramBlock.ramUsageText
                    font.bold: true
                    font.pixelSize: 12
                    color:theme.font.ram
                }
            }
        }

        // CPU Block
        Rectangle {
            id: cpuBlock
            height: 35
            width: 80
            radius: 15
            color: theme.colors.cpu

            property real cpuUsage: 0

            Process {
                id: cpuProcess
                command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]
                running: true

                onRunningChanged: {
                    if (!running) restartTimer2.start()
                }

                stdout: SplitParser {
                    onRead: data => {
                        let usage = parseFloat(data.trim())
                        if (!isNaN(usage)) cpuBlock.cpuUsage = usage
                    }
                }
            }

            Timer {
                id: restartTimer2
                interval: 1000
                onTriggered: cpuProcess.running = true
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                ColorOverlay{
                     height: 20 
                     width: 20 
                     source:Image { source: "icons/cpu.svg";}
                     color:theme.icon.cpu
                }

                Text {
                    text: Math.round(cpuBlock.cpuUsage) + "%"
                    font.bold: true
                    font.pixelSize: 12
                    color: theme.font.cpu
                }
            }
        }

        // Battery Block
        Rectangle {
            id: batteryBlock
            height: 35
            width: 80
            radius: 15
            color: theme.colors.battery

            property real batteryLevel: 0

            Process {
                id: batteryProcess
                command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity"]
                running: true

                onRunningChanged: {
                    if (!running) batteryRestartTimer.start()
                }

                stdout: SplitParser {
                    onRead: data => {
                        let level = parseInt(data.trim())
                        if (!isNaN(level)) batteryBlock.batteryLevel = level
                    }
                }
            }

            Timer {
                id: batteryRestartTimer
                interval: 5000
                onTriggered: batteryProcess.running = true
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                

                FileView {
                    id: batteryStatus
                    path: "/sys/class/power_supply/BAT0/status"
                    blockLoading: true
                }
 
                ColorOverlay{
                    height: 20
                    width: 20 
                    source:Image { source: batteryStatus.text().trim() === "Charging"
                                ? "icons/battery-charging.svg"
                                : "icons/battery.svg";     
                    }
                    color:theme.icon.battery
                }

                Timer {
                    interval: 5000   // Every 5 seconds
                    running: true
                    repeat: true
                    onTriggered: batteryStatus.reload()
                    }

                Text {
                    text: batteryBlock.batteryLevel + "%"
                    font.bold: true
                    font.pixelSize: 12
                    color:theme.font.battery
                }
            }
        }

        // Temperature Block
        Rectangle {
            id: tempBlock
            height: 35
            width: 80
            radius: 15
            color: theme.colors.temp

            property real temperature: 0

            Process {
                id: tempProcess
                command: ["cat", "/sys/class/thermal/thermal_zone0/temp"]
                running: true

                onRunningChanged: {
                    if (!running) restartTimer3.start()
                }

                stdout: SplitParser {
                    onRead: data => {
                        let temp = parseInt(data.trim()) / 1000.0
                        if (!isNaN(temp)) tempBlock.temperature = temp
                    }
                }
            }

            Timer {
                id: restartTimer3
                interval: 2000
                onTriggered: tempProcess.running = true
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 3
                ColorOverlay{
                    height: 20
                    width: 20
                    source:Image { 
                        source:"icons/thermometer.svg"
                     }
                    color: theme.icon.temp
                    }
                Text {
                    text: Math.round(tempBlock.temperature) + "°C"
                    font.bold: true
                    font.pixelSize: 12
                    color: theme.font.temp
                }
            }
        }

        // Time
        Rectangle {
            height: 35
            width: 80
            radius: 15
            color: theme.colors.clock

            Row {
                spacing: 3
                anchors.centerIn: parent

                ColorOverlay{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 0 
                    width: 16 
                    height: 16  
                    source:Image {
                    source: "icons/clock.svg"
                    fillMode: Image.PreserveAspectFit
                    }
                    color:theme.icon.clock
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "hh:mm:ss")
                    color: theme.font.clock
                    font.bold: true
                    font.pixelSize: 11
                    verticalAlignment: Text.AlignVCenter
                    
                }
            }
        }

        // System Tray
        Rectangle {
            height: 35
            width: 80
            radius: 15
            color: theme.colors.tray

            Row {
                id: trayRow
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: SystemTray.items

                    Image {
                        source: modelData.icon
                        width: 24
                        height: 24

                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = "icons/circle.svg"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if (modelData.hasMenu) {
                                    modelData.display(panel, parent.width * 100, mouseY)
                                } else {
                                    modelData.activate()
                                }
                            }

                            onEntered: parent.opacity = 0.6
                            onExited: parent.opacity = 1.0
                        }
                    }
                }
            }
        }

        // Power Button
        Rectangle {
            color: theme.colors.power
            height: 35
            width: 35
            radius: 20

            ColorOverlay {  
                anchors.centerIn: parent  
                anchors.horizontalCenterOffset: -1  
                anchors.verticalCenterOffset: -1  
                width: 24  
                height: 24  
                source: Image {  
                source: "icons/power.svg"  
                width: 24  
                height: 24  
                fillMode: Image.PreserveAspectFit  
                visible: false  
                }  
                color:theme.icon.power 
                }
            MouseArea{  
                anchors.fill: parent    
                onClicked: {  
                    if (powerMenuPopup.item) {  
                        powerMenuPopup.item.visible = !powerMenuPopup.item.visible  
                    }  
                }  
            }
        }
    }

        LazyLoader {  
            id: powerMenuPopup  
            loading: true  // Start loading immediately with shell  
            source: "PowerMenu.qml"  // Path to your power menu file  
        } 
    
}