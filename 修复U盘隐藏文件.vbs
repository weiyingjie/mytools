Set ws = CreateObject("Wscript.Shell") 
ws.run "cmd /c attrib -s -h -r *.* /s /d",vbhide 

msgbox "执行完成",6,"提示"