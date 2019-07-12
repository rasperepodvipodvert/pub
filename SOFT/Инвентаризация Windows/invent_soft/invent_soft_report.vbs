'Инвентаризация установленных программ и обновлений средствами WMI и VBScript (24.08.2010)
'Сборка общего отчета в форматах CSV и HTML из отдельных файлов CSV
'Подробности - см. http://zheleznov.info/invent_soft.htm
'Автор: Павел Железнов

'== НАСТРОЙКИ

'настройки для инвентаризации программ
Const TITLE = "Инвентаризация установленных программ" 'заголовок отчета и диалоговых окон
Const DATA_DIR = "soft\" 'каталог для сохранения отчетов + "\" в конце
'Const DATA_DIR = "\\SRV\Invent\soft\" 'сетевой ресурс для сохранения отчетов + "\" в конце
Const REPORT_FILE = "soft_report_%DATE%" 'имя файла для сохранения отчета, без расширения

'настройки для инвентаризации обновлений
'Const TITLE = "Инвентаризация установленных обновлений" 'заголовок отчета и диалоговых окон
'Const DATA_DIR = "updates\" 'каталог для сохранения отчетов + "\" в конце
'Const DATA_DIR = "\\SRV\Invent\updates\" 'сетевой ресурс для сохранения отчетов + "\" в конце
'Const REPORT_FILE = "updates_report_%DATE%" 'имя файла для сохранения отчета, без расширения

'прочие настройки
Const DATA_EXT = ".csv" 'расширение файла
Const HEAD_LINE = True 'пропустить первую строку в файле CSV - заголовок

'не завершать скрипт аварийно
On Error Resume Next

'== ВЫПОЛНЕНИЕ

'данные для построения матрицы
'т.к. количество программ и количество компьютеров заранее не известно, используются динамические массивы
Dim soft() 'индекс -> наименование программы
Dim list() 'индекс -> перечень компьютеров через ";"

'перечень всех компьютеров для шапки - в строке с индексом 0
ReDim soft(0)
ReDim list(0)
soft(0) = "*" 'условное название, не выводится в отчете
list(0) = ""

'прочитать все CSV-файлы в указанном каталоге
Dim fso, dir, fc, f
Set fso = CreateObject("Scripting.FileSystemObject")
Set dir = fso.GetFolder(DATA_DIR)
Set fc = dir.Files
For Each f in fc
	If Right(f.Name, 4) = DATA_EXT Then ReadCSV(dir.Path & "\" & f.Name)
Next

'из строки с индексом 0 получить массив имен компьютеров
Dim comp
comp = Split(Right(list(0), Len(list(0)) - 1), ";") 'отбросить один символ слева

'массивы для сортировки программ и компьютеров
Dim i, ordi, j, ordj
ordi = OrderArray(soft)
ordj = OrderArray(comp)

'вывести отчет
ReportCSV
ReportHTML

'== ПОДПРОГРАММЫ

'извлечь данные из файла CSV и добавить в массив программ
Sub ReadCSV(fname)
	Dim tf, name, i, s, a
	Set tf = fso.OpenTextFile(fname)
	If HEAD_LINE Then tf.ReadLine 'пропустить первую строку
	'определить имя компьютера из имени файла
	i = InStrRev(fname, "\")
	name = Mid(fname, i + 1, Len(fname) - Len(".csv") - i)
	'добавить сам компьютер в массив
	AddSoft "*", name
	'добавить программы в массив
	Do Until tf.AtEndOfStream
		s = tf.ReadLine
		a = Split(s, ";")
		AddSoft a(0), name
	Loop
	tf.Close
End Sub

'если программа уже есть, изменить значение - добавить компьютер
'если программы нет в массиве - добавить, значение = компьютер
Sub AddSoft(name, comp)
	Dim i
	i = IndexSoft(name)
	If i > -1 Then 'уже есть
		list(i) = list(i) & ";" & comp
	Else 'добавить программу
		i = UBound(soft) + 1
		ReDim Preserve soft(i), list(i)
		soft(i) = name
		list(i) = comp
	End If
End Sub

'определить индекс элемента массива по его значению
'если значение не найдено, вернуть -1
Function IndexSoft(s)
	IndexSoft = -1
	Dim i
	For i = 0 To UBound(soft)
		If soft(i) = s Then
			IndexSoft = i
			Exit For
		End If
	Next
End Function

'вернуть массив для отображения исходного массива в упорядоченный
Function OrderArray(arr)
	Dim max, ord(), bubble, i, t
	max = UBound(arr)
	ReDim ord(max)
	For i = 0 To max
		ord(i) = i
	Next
	Do
		bubble = False
		For i = 0 To max - 1
			If arr(ord(i)) > arr(ord(i + 1)) Then 'сортируем по возрастанию
				bubble = True
				t = ord(i)
				ord(i) = ord(i + 1)
				ord(i + 1) = t
			End If
		Next
	Loop While bubble
	OrderArray = ord
End Function

'вывести данные в отчет формата HTML
Sub ReportHTML
	'файл отчета
	Dim rep, fname
	fname = Replace(REPORT_FILE, "%DATE%", Date) & ".htm"
	Set rep = fso.CreateTextFile(fname, True)
	'вывести шапку отчета
	rep.WriteLine "<html><head>"
	rep.WriteLine "<title>" & TITLE & "</title>"
	rep.WriteLine "<meta http-equiv=""Content-Type"" content=""text/html; charset=windows-1251"" />"
	rep.WriteLine "<style><!-- "
	rep.WriteLine "body,table {font:10pt Arial, sans-serif}"
	rep.WriteLine "tr,td,th {border:1px solid gray; padding:4px}"
	rep.WriteLine "td.x {background:#afa; text-align:center}"
	rep.WriteLine "table {border-collapse:collapse}"
	rep.WriteLine "--></style>"
	rep.WriteLine "</head><body>"
	rep.WriteLine "<h3>" & TITLE & ", " & Date & "</h3>"
	rep.WriteLine "<table>"
	'вывести строку заголовков
	rep.Write "<tr><th>Программы</th>"
	For j = 0 To UBound(comp)
		rep.Write "<th>" & comp(ordj(j)) & "</th>"
	Next
	rep.WriteLine "</tr>"
	'вывести массив данных
	For i = 1 To UBound(soft)
		If soft(ordi(i)) <> "*" Then 'не выводить "условную" строку
			rep.Write "<tr><td>" & soft(ordi(i)) & "</td>"
			For j = 0 To UBound(comp)
				If InStr(";" & list(ordi(i)) & ";", ";" & comp(ordj(j)) & ";") > 0 Then
					rep.Write "<td class=""x"">+</td>"
				Else
					rep.Write "<td>-</td>"
				End If
			Next
			rep.WriteLine "</tr>"
		End If
	Next
	'вывести подвал отчета
	rep.WriteLine "</table>"
	rep.WriteLine "</body></html>"
	'закрыть файл
	rep.Close
	MsgBox "Отчет в формате HTML сохранен в файл:" & vbCrLf & fname, vbInformation, TITLE
End Sub

'вывести данные в отчет формата CSV
Sub ReportCSV
	'файл отчета
	Dim rep, fname
	fname = Replace(REPORT_FILE, "%DATE%", Date) & ".csv"
	Set rep = fso.CreateTextFile(fname, True)
	'вывести строку заголовков
	rep.Write "Программы"
	For j = 0 To UBound(comp)
		rep.Write ";" & comp(ordj(j))
	Next
	rep.WriteLine
	'вывести массив данных
	For i = 1 To UBound(soft)
		If soft(ordi(i)) <> "*" Then 'не выводить "условную" строку
			rep.Write soft(ordi(i))
			For j = 0 To UBound(comp)
				If InStr(";" & list(ordi(i)) & ";", ";" & comp(ordj(j)) & ";") > 0 Then
					rep.Write ";1"
				Else
					rep.Write ";-"
				End If
			Next
			rep.WriteLine
		End If
	Next
	'закрыть файл
	rep.Close
	MsgBox "Отчет в формате CSV сохранен в файл:" & vbCrLf & fname, vbInformation, TITLE
End Sub