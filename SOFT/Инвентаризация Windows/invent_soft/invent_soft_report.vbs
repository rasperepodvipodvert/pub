'�������������� ������������� �������� � ���������� ���������� WMI � VBScript (24.08.2010)
'������ ������ ������ � �������� CSV � HTML �� ��������� ������ CSV
'����������� - ��. http://zheleznov.info/invent_soft.htm
'�����: ����� ��������

'== ���������

'��������� ��� �������������� ��������
Const TITLE = "�������������� ������������� ��������" '��������� ������ � ���������� ����
Const DATA_DIR = "soft\" '������� ��� ���������� ������� + "\" � �����
'Const DATA_DIR = "\\SRV\Invent\soft\" '������� ������ ��� ���������� ������� + "\" � �����
Const REPORT_FILE = "soft_report_%DATE%" '��� ����� ��� ���������� ������, ��� ����������

'��������� ��� �������������� ����������
'Const TITLE = "�������������� ������������� ����������" '��������� ������ � ���������� ����
'Const DATA_DIR = "updates\" '������� ��� ���������� ������� + "\" � �����
'Const DATA_DIR = "\\SRV\Invent\updates\" '������� ������ ��� ���������� ������� + "\" � �����
'Const REPORT_FILE = "updates_report_%DATE%" '��� ����� ��� ���������� ������, ��� ����������

'������ ���������
Const DATA_EXT = ".csv" '���������� �����
Const HEAD_LINE = True '���������� ������ ������ � ����� CSV - ���������

'�� ��������� ������ ��������
On Error Resume Next

'== ����������

'������ ��� ���������� �������
'�.�. ���������� �������� � ���������� ����������� ������� �� ��������, ������������ ������������ �������
Dim soft() '������ -> ������������ ���������
Dim list() '������ -> �������� ����������� ����� ";"

'�������� ���� ����������� ��� ����� - � ������ � �������� 0
ReDim soft(0)
ReDim list(0)
soft(0) = "*" '�������� ��������, �� ��������� � ������
list(0) = ""

'��������� ��� CSV-����� � ��������� ��������
Dim fso, dir, fc, f
Set fso = CreateObject("Scripting.FileSystemObject")
Set dir = fso.GetFolder(DATA_DIR)
Set fc = dir.Files
For Each f in fc
	If Right(f.Name, 4) = DATA_EXT Then ReadCSV(dir.Path & "\" & f.Name)
Next

'�� ������ � �������� 0 �������� ������ ���� �����������
Dim comp
comp = Split(Right(list(0), Len(list(0)) - 1), ";") '��������� ���� ������ �����

'������� ��� ���������� �������� � �����������
Dim i, ordi, j, ordj
ordi = OrderArray(soft)
ordj = OrderArray(comp)

'������� �����
ReportCSV
ReportHTML

'== ������������

'������� ������ �� ����� CSV � �������� � ������ ��������
Sub ReadCSV(fname)
	Dim tf, name, i, s, a
	Set tf = fso.OpenTextFile(fname)
	If HEAD_LINE Then tf.ReadLine '���������� ������ ������
	'���������� ��� ���������� �� ����� �����
	i = InStrRev(fname, "\")
	name = Mid(fname, i + 1, Len(fname) - Len(".csv") - i)
	'�������� ��� ��������� � ������
	AddSoft "*", name
	'�������� ��������� � ������
	Do Until tf.AtEndOfStream
		s = tf.ReadLine
		a = Split(s, ";")
		AddSoft a(0), name
	Loop
	tf.Close
End Sub

'���� ��������� ��� ����, �������� �������� - �������� ���������
'���� ��������� ��� � ������� - ��������, �������� = ���������
Sub AddSoft(name, comp)
	Dim i
	i = IndexSoft(name)
	If i > -1 Then '��� ����
		list(i) = list(i) & ";" & comp
	Else '�������� ���������
		i = UBound(soft) + 1
		ReDim Preserve soft(i), list(i)
		soft(i) = name
		list(i) = comp
	End If
End Sub

'���������� ������ �������� ������� �� ��� ��������
'���� �������� �� �������, ������� -1
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

'������� ������ ��� ����������� ��������� ������� � �������������
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
			If arr(ord(i)) > arr(ord(i + 1)) Then '��������� �� �����������
				bubble = True
				t = ord(i)
				ord(i) = ord(i + 1)
				ord(i + 1) = t
			End If
		Next
	Loop While bubble
	OrderArray = ord
End Function

'������� ������ � ����� ������� HTML
Sub ReportHTML
	'���� ������
	Dim rep, fname
	fname = Replace(REPORT_FILE, "%DATE%", Date) & ".htm"
	Set rep = fso.CreateTextFile(fname, True)
	'������� ����� ������
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
	'������� ������ ����������
	rep.Write "<tr><th>���������</th>"
	For j = 0 To UBound(comp)
		rep.Write "<th>" & comp(ordj(j)) & "</th>"
	Next
	rep.WriteLine "</tr>"
	'������� ������ ������
	For i = 1 To UBound(soft)
		If soft(ordi(i)) <> "*" Then '�� �������� "��������" ������
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
	'������� ������ ������
	rep.WriteLine "</table>"
	rep.WriteLine "</body></html>"
	'������� ����
	rep.Close
	MsgBox "����� � ������� HTML �������� � ����:" & vbCrLf & fname, vbInformation, TITLE
End Sub

'������� ������ � ����� ������� CSV
Sub ReportCSV
	'���� ������
	Dim rep, fname
	fname = Replace(REPORT_FILE, "%DATE%", Date) & ".csv"
	Set rep = fso.CreateTextFile(fname, True)
	'������� ������ ����������
	rep.Write "���������"
	For j = 0 To UBound(comp)
		rep.Write ";" & comp(ordj(j))
	Next
	rep.WriteLine
	'������� ������ ������
	For i = 1 To UBound(soft)
		If soft(ordi(i)) <> "*" Then '�� �������� "��������" ������
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
	'������� ����
	rep.Close
	MsgBox "����� � ������� CSV �������� � ����:" & vbCrLf & fname, vbInformation, TITLE
End Sub