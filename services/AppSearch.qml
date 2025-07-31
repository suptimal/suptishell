pragma Singleton

import "../functions/fuzzysort.js" as Fuzzy
import "../functions/levendist.js" as Levendist
import Quickshell
import Quickshell.Io

/**
 * - Eases fuzzy searching for applications by name
 * - Guesses icon name for window class name
 */
Singleton {
    id: root
    property string steamIcons: ""
    property bool sloppySearch: false
    property real scoreThreshold: 0.2
    property var overwrites: ({
        "krita": "viosual-studio-code",
    })
    property var substitutions: ({
        "code-url-handler": "visual-studio-code",
        "gnome-tweaks": "org.gnome.tweaks",
        "pavucontrol-qt": "pavucontrol",
        "wps": "wps-office2019-kprometheus",
        "wpsoffice": "wps-office2019-kprometheus",
        "footclient": "foot",
        "zen": "zen-browser",
        "brave-browser": "brave-desktop",
        "TeamSpeak 3": "teamspeak"
    })
    property var regexSubstitutions: [
        {
            "regex": /^steam_app_(\d+)$/,
            "replace": "steam_icon_$1"
        },
        {
            "regex": /Minecraft.*/,
            "replace": "minecraft"
        },
        {
            "regex": /.*polkit.*/,
            "replace": "system-lock-screen"
        },
        {
            "regex": /gcr.prompter/,
            "replace": "system-lock-screen"
        }
    ]

    readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values)
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var preppedNames: list.map(a => ({
                name: Fuzzy.prepare(`${a.name} `),
                entry: a
            }))

    function fuzzyQuery(search: string): var { // Idk why list<DesktopEntry> doesn't work
        if (root.sloppySearch) {
            const results = list.map(obj => ({
                entry: obj,
                score: Levendist.computeScore(obj.name.toLowerCase(), search.toLowerCase())
            })).filter(item => item.score > root.scoreThreshold)
                .sort((a, b) => b.score - a.score)
            return results
                .map(item => item.entry)
        }

        return Fuzzy.go(search, preppedNames, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry
        });
    }

    function iconExists(iconName) {
        if (!iconName || iconName.length == 0) return false;
        return (Quickshell.iconPath(iconName, true).length > 0) 
            && !iconName.includes("image-missing");
    }

    function getIconById(client_id) {
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === client_id) {
                return list[i].icon;
            }
        }
        return null; // not found
    }


    function steamIconPath(appid) {
        if (!appid || root.steamIcons.length == 0)
            return "";

        const lines = root.steamIcons.trim().split("\n");
        const basePath = `/librarycache/${appid}/`;

        for (let i = 0; i < lines.length; ++i) {
            const line = lines[i];
            if (line.includes(basePath)) {
                return line;
            }
        }

        return "";
    }

    function guessIcon(str) {
        if (!str || str.length == 0) return Quickshell.iconPath("image-missing");

        // Normal substitutions
        if (substitutions[str])
            return Quickshell.iconPath(substitutions[str]);

        // Regex substitutions
        for (let i = 0; i < regexSubstitutions.length; i++) {
            const substitution = regexSubstitutions[i];
            const replacedName = str.replace(
                substitution.regex,
                substitution.replace,
            );
            if (replacedName != str && iconExists(replacedName)) return Quickshell.iconPath(replacedName);
        }

        // if start with steam_app_ get icon from steamLibrarycacheIcon(appid)
        if (str.startsWith("steam_app_")) {
            const appid = str.substring("steam_app_".length);
            const iconPath = steamIconPath(appid);
            if (iconPath != "") return "file://"+iconPath
        }

        // If it gets detected normally, no need to guess
        if (iconExists(str)) return Quickshell.iconPath(str);

        // Guess: prefix (application-x-)
        if (iconExists("application-x-" + str)) return Quickshell.iconPath("application-x-" + str);
        if (iconExists("application-x-" + str.toLowerCase())) return Quickshell.iconPath("application-x-" + str.toLowerCase());

        // Guess: Check id in desktop entrys
        let byid = getIconById(str)
        if (iconExists(byid)) return Quickshell.iconPath(byid);
        byid = getIconById(str.toLowerCase())
        if (iconExists(byid)) return Quickshell.iconPath(byid);


        // Guess: Take only app name of reverse domain name notation
        let guessStr = str;
        guessStr = str.split('.').slice(-1)[0];
        if (iconExists(guessStr)) return Quickshell.iconPath(guessStr);
        guessStr = str.split('.').slice(-1)[0].toLowerCase();
        if (iconExists(guessStr)) return Quickshell.iconPath(guessStr);

        // Guess: normalize to kebab case
        guessStr = str.toLowerCase().replace(/\s+/g, "-");
        if (iconExists(guessStr)) return Quickshell.iconPath(guessStr);

        // Guess: First fuzzy desktop entry match
        const searchResults = root.fuzzyQuery(str);
        if (searchResults.length > 0) {
            const firstEntry = searchResults[0];
            guessStr = firstEntry.icon
            if (iconExists(guessStr)) return Quickshell.iconPath(guessStr);
        }

        // Give up
        return Quickshell.iconPath(str);
    }
Process {
    id: getSteamIcons
    command: [
        "sh", "-c",
        "find ~/.local/share/Steam/appcache/librarycache/ -type f -regextype posix-extended -regex '.*/[a-f0-9]{40}\\.[a-z]{3,4}'"
    ]
    stdout: StdioCollector {
        onStreamFinished: {
            root.steamIcons = data;
        }
    }
    running: true
}
}
