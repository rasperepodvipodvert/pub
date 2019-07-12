'Инвентаризация установленных программ и обновлений средствами WMI и VBScript (24.08.2010)
'Отчет в отдельном файле CSV для последующей сборки общего отчета
'Подробности - см. http://zheleznov.info/invent_soft.htm
'Автор: Павел Железнов

'== НАСТРОЙКИ

'настройки для инвентаризации программ
Const UPDATES = False 'не учитывать обновления
Const TITLE = "Инвентаризация установленных программ" 'заголовок диалоговых окон
Const DATA_DIR = "soft\" 'каталог для сохранения отчетов + "\" в конце
'Const DATA_DIR = "\\SRV\Invent\soft\" 'сетевой ресурс для сохранения отчетов + "\" в конце

'настройки для инвентаризации обновлений
'Const UPDATES = True 'учитывать только обновления
'Const TITLE = "Инвентаризация установленных обновлений" 'заголовок диалоговых окон
'Const DATA_DIR = "updates\" 'каталог для сохранения отчетов + "\" в конце
'Const DATA_DIR = "\\SRV\Invent\updates\" 'сетевой ресурс для сохранения отчетов + "\" в конце

'прочие настройки
Const DATA_EXT = ".csv" 'расширение файла отчета
'Const SILENT = False 'тихий режим отключен, будет запрошено имя компьютера
Const SILENT = True 'режим отчета о локальном компьютере без вывода диалогов
Const HEAD_LINE = True 'выводить заголовки в первой строке CSV-файла

'не завершать скрипт аварийно
On Error Resume Next

'== ВЫПОЛНЕНИЕ

'глобальные переменные
Dim comp, wmio

'узнать имя локального компьютера
Dim nwo
Set nwo = CreateObject("WScript.Network")
comp = LCase(nwo.ComputerName)

'запросить имя удаленного компьютера
If Not SILENT Then
	comp = InputBox("Введите имя компьютера:", TITLE, comp)
	'проверить доступность компьютера
	If Len(comp) > 0 And Unavailable(comp) Then
		MsgBox "Компьютер недоступен:" & vbCrLf & comp, vbExclamation, TITLE
		comp = ""
	End If
End If

'провести инвентаризацию
If Len(comp) > 0 Then InventSoft

'если ошибка
If Len(Err.Description) > 0 Then _
	If Not SILENT Then MsgBox comp & vbCrLf & "Ошибка:" & vbCrLf & Err.Description, vbExclamation, TITLE

'== ПОДПРОГРАММЫ

'обращение к WMI оформлено в подпрограмму, чтобы можно было корректно обработать возможную ошибку
Sub InventSoft

	'подключить реестр удаленного компьютера через WMI
	Set wmio = GetObject("WinMgmts:{impersonationLevel=impersonate}!\\" & comp & "\Root\default:StdRegProv")

	'создать файл отчета
	Dim fso, tf
	Set fso = CreateObject("Scripting.FileSystemObject")
	If Not fso.FolderExists(DATA_DIR) Then
		If Not SILENT Then MsgBox "Не найден каталог для сохранения отчета:" & vbCrLf & DATA_DIR, vbExclamation, TITLE
		Exit Sub
	End If
	Set tf = fso.CreateTextFile(DATA_DIR & comp & DATA_EXT, True)

	'записать заголовки столбцов
	If HEAD_LINE Then tf.WriteLine "Название и версия;Производитель;Дата установки"

	'искать программы и оформить текст для отчета
	Dim s
	s = ExtractSoft("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\")
	If Len(s) > 0 Then tf.Write s

	'для 64-битных систем есть еще другой ключ! (32-битные программы на 64-битной системе)
	s = ExtractSoft("SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\")
	If Len(s) > 0 Then tf.Write s

	'закрыть файл отчета
	tf.Close
	If Not SILENT Then MsgBox "Отчет сохранен в файл:" & vbCrLf & DATA_DIR & comp & DATA_EXT, vbInformation, TITLE

End Sub

'проверить указанный ключ реестра; вернуть строку для записи в файл отчета
Function ExtractSoft(key)

	'получить коллекцию
	Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE
	Dim items
	wmio.EnumKey HKLM, key, items
	If IsNull(items) Then
		ExtractSoft = ""
		Exit Function
	End If

	'отобрать нужные элементы
	Dim s, item, ok, name, publ, inst, x, prev
	s = "" 'результат накапливать в строке
	For Each item In items

		ok = True 'флаг продолжения

		'название, пропускать пустые и повторяющиеся
		prev = name
		wmio.GetStringValue HKLM, key & item, "DisplayName", name
		If IsNull(name) Or Len(name) = 0 Or name = prev Then
			ok = False
		Else 'не допускать символ ";"
			name = Replace(name, ";", "_")
		End If

		'отделить заплатки, по значению параметра ParentKeyName = "OperatingSystem"
		If ok Then
			wmio.GetStringValue HKLM, key & item, "ParentKeyName", x
			'для программ
			If UPDATES Then
				If IsNull(x) Or x <> "OperatingSystem" Then ok = False
			'для обновлений
			Else
				If Not IsNull(x) And x = "OperatingSystem" Then ok = False
			End If
		End If

		'дата установки
		If ok Then
			wmio.GetStringValue HKLM, key & item, "InstallDate", inst
			If IsNull(inst) Or Len(inst) < 8 Then
				inst = "-"
			Else 'преобразовать в читаемый вид
				inst = Mid(inst, 7, 2) & "." & Mid(inst, 5, 2) & "." & Left(inst, 4)
			End If
		End If

		'производитель
		If ok Then
			wmio.GetStringValue HKLM, key & item, "Publisher", publ
			If IsNull(publ) Or Len(publ) = 0 Then publ = "-"
		End If

		If ok Then s = s & name & ";" & publ & ";" & inst & vbCrLf

	Next
	ExtractSoft = s

End Function

'проверить доступность компьютера в сети; вернуть True, если адрес недоступен
Function Unavailable(addr)
	Dim wmio, ping, p
	Set wmio = GetObject("WinMgmts:{impersonationLevel=impersonate}")
	Set ping = wmio.ExecQuery("SELECT StatusCode FROM Win32_PingStatus WHERE Address = '" & addr & "'")
	For Each p In ping
		If IsNull(p.StatusCode) Then
			Unavailable = True
		Else
			Unavailable = (p.StatusCode <> 0)
		End If
	Next
End Function