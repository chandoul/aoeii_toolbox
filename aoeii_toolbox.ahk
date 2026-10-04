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

gameGroup := toolsGui.AddGroupBox('w200 h200', 'My Game')
locateGame := toolsGui.AddButton('xp+25 yp+40 w150', 'Locate...')
repairGame := toolsGui.AddButton('wp', 'Repair')
downloadGame := toolsGui.AddButton('wp', 'Download')

statusBar := toolsGui.AddStatusBar()
statusBar.SetParts(150)
statusBar.SetText('Select your game...')

#HotIf WinActive(toolsGui)
^r:: Reload()
#HotIf

class aoeii_toolbox {
    static package => JSON.LoadFile('package.json')
}