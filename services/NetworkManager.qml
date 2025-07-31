pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

/**
 * Simple polled network state service.
 */
Singleton {
    id: root

    property bool wifi: true
    property bool ethernet: true
    property int updateInterval: 1000
    property string networkName: ""
    property string networkConnectivity: "full"
    property int networkStrength
    property string networkSymbol: ethernet && !wifi ? "lan" :
        (root.networkName.length > 0 && root.networkName != "lo") ? (
        root.networkStrength > 80 ? "network-wireless-signal-excellent" :
        root.networkStrength > 60 ? "network-wireless-signal-good" :
        root.networkStrength > 40 ? "network-wireless-signal-ok" :
        root.networkStrength > 20 ? "network-wireless-signal-low" :
        "network-wireless-signal-low"
    ) : "network-wireless-signal-none"
    function update() {
        updateConnectionType.running = true;
        updateNetworkName.running = true;
        updateNetworkStrength.running = true;
        updateNetworkConnectivity.running = true;
    }

    Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            root.update();
            interval = root.updateInterval;
        }
    }

    Process {
        id: updateConnectionType
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "c", "show", "--active"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split('\n');
                let hasEthernet = false;
                let hasWifi = false;
                lines.forEach(line => {
                    if (line.includes("ethernet"))
                        hasEthernet = true;
                    else if (line.includes("wireless"))
                        hasWifi = true;
                });
                root.ethernet = hasEthernet;
                root.wifi = hasWifi;
            }
        }
    }

    Process {
        id: updateNetworkName
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.networkName = data;
            }
        }
    }

    Process {
        id: updateNetworkStrength
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => {
                root.networkStrength = parseInt(data);
            }
        }
    }
    Process {
        id: updateNetworkConnectivity
        running: true
        command: ["nmcli", "networking", "connectivity"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.networkConnectivity = text.trim();
            }
        }
    }
}