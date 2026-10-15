#SingleInstance Force
#Requires AutoHotkey v2.0

#Include <cJSON>

toolsGui := Gui(, Format(
    '{} v{}', aoeii_toolbox.package['name']
    , aoeii_toolbox.package['version']
))
toolsGui.SetFont('bold', 'Tahoma')
toolsGui.BackColor := 'FFFFFF'
toolsGui.MarginX := toolsGui.MarginY := 10
toolsGui.Show('w1000 h500')

gameGroup := toolsGui.AddGroupBox('w200 h200 cff0000', 'My Game')
locateGame := toolsGui.AddButton('xp+25 yp+40 w150', 'Locate...')
locateGame.OnEvent('Click', (*) => aoeii_toolbox.gameSelector.select())
repairGame := toolsGui.AddButton('wp', 'Repair')
downloadGame := toolsGui.AddButton('wp', 'Download')

statusBar := toolsGui.AddStatusBar()
statusBar.SetText(
    (!aoeii_toolbox.userPackage.Has('location') || !aoeii_toolbox.gameSelector.valid(aoeii_toolbox.userPackage['location'])) ?
        'The game is not located yet, please locate it to unlock all of app`'s features...' :
    Format('Game folder: "{}"', aoeii_toolbox.userPackage['location'])
)


#HotIf WinActive(toolsGui)
^r:: Reload()
#HotIf

class aoeii_toolbox {
    static packageLink => 'https://raw.githubusercontent.com/chandoul/aoeii_toolbox/refs/heads/main/package.json'
    static package => this.appPackage()
    static userPackagePath => A_AppData '\aoeii_toolbox\package.json'
    static userPackage => this.appUserPackage()

    static appUserPackage() {
        SplitPath(this.userPackagePath, , &dir)
        DirCreate(dir)
        content := FileExist(this.userPackagePath) ? FileRead(this.userPackagePath) : ''
        return this.jsonLoad(content)
    }

    static appPackage() {
        content := ''
        content := FileExist('package.json') ? FileRead('package.json') : this.fetch(this.packageLink)
        return this.jsonLoad(content)
    }

    static fetch(link) {
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", link, True)
            whr.Send()
            whr.WaitForResponse()
            text := whr.ResponseText
            whr := ''
        } catch {
            Download(link, A_Temp '\link.txt')
            text := FileRead(A_Temp '\link.txt')
        }
        return text
    }

    static jsonLoad(content) {
        obj := Map()
        try obj := JSON.Load(content)
        return obj
    }

    static jsonAppend(key, value, jsonPath := this.userPackagePath) {
        jsonData := this.jsonLoad(FileExist(jsonPath) ? FileRead(jsonPath) : '')
        jsonData[key] := value
        JSON.DumpFile(jsonData, jsonPath, '`t')
    }

    class gameSelector {
        static select() {
            location := FileSelect('D')
            if this.valid(location)
                aoeii_toolbox.jsonAppend('location', location)
        }

        static valid(location) {
            return (
                FileExist(Format('{}\empires2.exe', location)) &&
                FileExist(Format('{}\language.dll', location))
            )
        }
    }
}