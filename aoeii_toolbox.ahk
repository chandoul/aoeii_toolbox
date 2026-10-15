#SingleInstance Force
#Requires AutoHotkey v2.0

#Include <cJSON>
#Include <CNG>

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
^g:: aoeii_toolbox.utils.generateFolderHash()
#HotIf

class aoeii_toolbox {
    static packageLink => 'https://raw.githubusercontent.com/chandoul/aoeii_toolbox/refs/heads/main/package.json'
    static package => this.appPackage()
    static userPackagePath => A_AppData '\aoeii_toolbox\package.json'
    static userPackage => this.appUserPackage()

    static __New() {
        SplitPath(this.userPackagePath, , &dir)
        DirCreate(dir)
    }

    static appUserPackage() {
        try return JSON.LoadFile(this.userPackagePath)
        catch
            return false
    }

    static appPackage() {
        try return JSON.Load(this.utils.fetch(this.packageLink))
        catch
            try return JSON.LoadFile('package.json')
            catch
                return false
    }

    class utils {
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

        static jsonAppend(key, value, jsonPath := aoeii_toolbox.userPackagePath) {
            try jsonData := JSON.LoadFile(jsonPath)
            catch
                jsonData := Map()
            jsonData[key] := value
            JSON.DumpFile(jsonData, jsonPath, '`t')
        }

        static generateFolderHash() {
            folder := FileSelect('D')
            SplitPath(folder, , &parent,, &name)
            fileObj := FileOpen(parent '\' name '.json', 'w')
            fileObj.Write('{`n')
            loop files folder '\*.*', 'R' {
                statusBar.SetText(A_LoopFileName '...')
                md5 := Hash.File('MD5', A_loopFileFullPath)
                filePath := StrReplace(A_loopFileFullPath, folder '\')
                filePath := StrReplace(filePath, '\', '\\')
                fileObj.Write(Format('`t"{}":"{}",`n', filePath, md5))
            }
            fileObj.Pos := fileObj.Pos - 2
            fileObj.Write('`n}')
            fileObj.Close()
        }
    }

    class gameSelector {
        static select() {
            location := FileSelect('D')
            if this.valid(location)
                aoeii_toolbox.utils.jsonAppend('location', location)
        }

        static valid(location) {
            return (
                FileExist(Format('{}\empires2.exe', location)) &&
                FileExist(Format('{}\language.dll', location))
            )
        }
    }
}