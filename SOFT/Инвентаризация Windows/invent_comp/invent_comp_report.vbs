'�������������� ����������� ���������� WMI � VBScript (11.06.2009)
'������ ������ HTML-������ �� ���� ����������� �� ��������� CSV-������
'����������� - ��. http://zheleznov.info/invent_comp.htm
'�����: ����� ��������

'== ���������

Const TITLE = "�������������� �����������" '��������� ������ � ���������� ����
Const DATA_DIR = "comp\" '������� ��� ���������� ������� + "\" � �����
'Const DATA_DIR = "\\SRV\Invent\comp\" '������� ������ ��� ���������� ������� + "\" � �����
Const DATA_EXT = ".csv" '���������� ������ � �������
Const HEAD_LINE = True '���������� ������ ������ � ����� CSV - ���������
Const REPORT_FILE = "comp_report_%DATE%.htm" '��� ����� ��� ���������� ������

'����������, ������� � �������� �������� ������
'�������� ������ ��������������� ������ ���� ����� CSV �����!
Dim col(21) '<-- �� ������ ��������� ������� ������!
col(0) = "���������;������� ���"
col(1) = "���������;UUID"
col(2) = "���������;������� ������������"
col(3) = "������������ �������;������������"
col(4) = "������������ �������;����������"
col(5) = "����������� �����;�������������"
col(6) = "����������� �����;������������"
col(7) = "���������;������������"
col(8) = "���������;������� (���)"
col(9) = "���������;����� ������ (��)"
col(10) = "������ ������;������ (��)"
col(11) = "������ ������;�������"
col(12) = "����;������������"
col(13) = "����;������ (��)"
col(14) = "����;���������"
col(15) = "CD-������;������������"
col(16) = "���������������;������������"
col(17) = "���������������;����� ������ (��)"
col(18) = "������� �������;������������"
col(19) = "������� �������;MAC-�����"
col(20) = "�������� ����������;������������"
col(21) = "�������;������������"

'����� � ������ ������ � ������� XHTML
'���������� ������������� ����� CSS ������ ���� <style>
Dim header, footer

header = "<html><head>" _
	& "<title>" & TITLE & "</title>" & vbCrLf _
	& "<meta http-equiv=""Content-Type"" content=""text/html; charset=windows-1251"" />" & vbCrLf _
	& "<style><!--" & vbCrLf _
	& "body,table {font: 10pt Arial, sans-serif}" & vbCrLf _
	& "table {border-collapse: collapse}" & vbCrLf _
	& "tr,td,th {border: 1px solid gray; padding: 8px}" & vbCrLf _
	& "td {vertical-align: top}" & vbCrLf _
	& "--></style>" & vbCrLf _
	& "</head><body>" & vbCrLf _
	& "<h3>" & TITLE & ", " & Date & "</h3>" & vbCrLf _
	& "<table>" & vbCrLf

footer = "</table>" & vbCrLf _
	& "</body></html>"

'�� ��������� ������ ��������
On Error Resume Next

'== ����������

'���� ������
Dim fso, report
Set fso = CreateObject("Scripting.FileSystemObject")
report = Replace(REPORT_FILE, "%DATE%", Date)
Set rep = fso.CreateTextFile(report, True)
rep.Write header

'����� �������
rep.WriteLine "<tr><th>" & Replace(Join(col, "</th><th>"), ";", ":") & "</th></tr>"

'��������� ��� CSV-�����
Dim dir, fc, f, row
Set dir = fso.GetFolder(DATA_DIR)
Set fc = dir.Files
For Each f in fc
	If Right(f.Name, 4) = DATA_EXT Then row = ReadCSV(dir.Path & "\" & f.Name)
	If Len(row) > 0 Then rep.WriteLine row
Next

'������� ���� ������
rep.Write footer
rep.Close
MsgBox "����� �������� � ����:" & vbCrLf & report, vbInformation, TITLE

'== ������������

'���������� ������ �������� ������� �� ��� ��������
'���� �������� �� �������, ������� -1
Function IndexCol(s)
	IndexCol = -1
	Dim i
	For i = 0 To UBound(col)
		If col(i) = s Then
			IndexCol = i
			Exit For
		End If
	Next
End Function

'������� ������ �� ����� CSV
'������������ � ������� ������ ������� � ������� XHTML
'� ������ ������ ������� ������ ������
Function ReadCSV(fname)
	Dim tf, s, a, k, i
	Dim v()
	ReDim v(UBound(col))
	'�������� �� ��������� - "-"
	For i = 0 To UBound(v)
		v(i) = "-"
	Next
	Set tf = fso.OpenTextFile(fname)
	If HEAD_LINE Then tf.ReadLine '���������� ������ ������
	Do Until tf.AtEndOfStream
		s = tf.ReadLine
		a = Split(s, ";")
		k = a(0) & ";" & a(1)
		i = IndexCol(k)
		If i > -1 Then
			If a(2) > 1 Then '��������� ����������� ����������� ";"
				v(i) = v(i) & ";" & a(3)
			Else
				v(i) = a(3)
			End If
		End If
	Loop
	tf.Close
	'��������� ����������� �������� ������� � ������� XHTML
	For i = 0 To UBound(v)
		'If InStr(v(i), ";") Then v(i) = Replace(v(i), ";", "<br />") '����� ������� ��� �������� �������?
		If InStr(v(i), ";") Then v(i) = "<ul><li>" & Replace(v(i), ";", "</li><li>") & "</li></ul>"
	Next
	ReadCSV = "<tr><td>" & Join(v, "</td><td>") & "</td></tr>"
End Function