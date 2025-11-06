#Requires AutoHotkey v2.0

explorerGethWnd(hwnd:="")  {
	; by WKen - modified (from: https://www.autohotkey.com/boards/viewtopic.php?t=114431)
	processName := WinGetProcessName("ahk_id " hwnd := hwnd? hwnd:WinExist("A"))
	class := WinGetClass("ahk_id " hwnd)
	if (processName!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")  {
		for window in ComObject("Shell.Application").Windows
			try if (window.hwnd==hwnd)
				return hwnd
	}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
}

GetCurrentExplorerPath(hwnd := WinExist("A")) { 
	; by lexikos - modified (from: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907)
 	if !(explorerHwnd := explorerGethWnd(hwnd))
		return ErrorLevel := "ERROR"
	; exclude "Start", "Catalog", "Trash", "Home" and "Network"
	if (explorerHwnd="desktop")
		return A_Desktop
	activeTab := 0
	activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
	for window in ComObject("Shell.Application").Windows {
		if window.hwnd != hwnd
			continue
		if activeTab { ; The window has tabs, so make sure this is the right one.
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			shellBrowser := ComObjQuery(window, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(3, shellBrowser, "uint*", &thisTab:=0)
			if thisTab != activeTab
				continue
		}
		if (type(window.Document) = "ShellFolderView")  {
			ExplorerPath := window.Document.Folder.Self.Path
			; exclude "Start", "Catalog", "Trash", "Home" and "Network"
			If (ExplorerPath = "::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}" || ExplorerPath = "::{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}" || ExplorerPath = "::{645FF040-5081-101B-9F08-00AA002F954E}" || ExplorerPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" || ExplorerPath = "::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")
				return ErrorLevel := "ERROR"
			else
				return ExplorerPath
		} 
		else
			return "ERROR"
	}
	Return "ERROR"
}

#HotIf WinActive("ahk_exe explorer.exe") ;仅在explorer.exe中生效
~^h:: {
	global
	path := GetCurrentExplorerPath()
	ofnames := SubStr(A_Clipboard, 1) ;ofname 代表原始文件名组的字符串（无引号）
	ofnamesArray := StrSplit(ofnames , "`r`n")
	For index, value in ofnamesArray
	{
		ofname := Trim(value, "`"") ;ofname 代表原始文件名（无引号）
		SplitPath(ofname, &filename) ;判断是否是文件夹
		AttributeString := FileExist(ofname)
		if(AttributeString = "D"){
			MsgBox("错误！不能创建文件夹的硬链接！")
		}
		HardlinkPath := path . "\" . filename ;HardlinkPath代表硬链接全路径
		AttributeString := FileExist(HardlinkPath) ;判断是否有同名文件
		if(AttributeString != ""){
			MsgBox("错误！当前目录存在同名文件！")
		}else if(SubStr(HardlinkPath, 1, 1)=SubStr(ofname, 1, 1))
		{
			sc := "mklink /H `"" . HardlinkPath . "`" `"" . ofname . "`""
			Run("cmd.exe /c " sc, , "hide")
		}else{
			MsgBox("错误！不能跨驱动器创建硬链接！")
		}
	}
}

#HotIf
