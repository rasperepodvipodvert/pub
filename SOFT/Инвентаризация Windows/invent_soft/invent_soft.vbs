'�������������� ������������� �������� � ���������� ���������� WMI � VBScript (24.08.2010)
'����� � ��������� ����� CSV ��� ����������� ������ ������ ������
'����������� - ��. http://zheleznov.info/invent_soft.htm
'�����: ����� ��������

'== ���������

'��������� ��� �������������� ��������
Const UPDATES = False '�� ��������� ����������
Const TITLE = "�������������� ������������� ��������" '��������� ���������� ����
Const DATA_DIR = "soft\" '������� ��� ���������� ������� + "\" � �����
'Const DATA_DIR = "\\SRV\Invent\soft\" '������� ������ ��� ���������� ������� + "\" � �����

'��������� ��� �������������� ����������
'Const UPDATES = True '��������� ������ ����������
'Const TITLE = "�������������� ������������� ����������" '��������� ���������� ����
'Const DATA_DIR = "updates\" '������� ��� ���������� ������� + "\" � �����
'Const DATA_DIR = "\\SRV\Invent\updates\" '������� ������ ��� ���������� ������� + "\" � �����

'������ ���������
Const DATA_EXT = ".csv" '���������� ����� ������
'Const SILENT = False '����� ����� ��������, ����� ��������� ��� ����������
Const SILENT = True '����� ������ � ��������� ���������� ��� ������ ��������
Const HEAD_LINE = True '�������� ��������� � ������ ������ CSV-�����

'�� ��������� ������ ��������
On Error Resume Next

'== ����������

'���������� ����������
Dim comp, wmio

'������ ��� ���������� ����������
Dim nwo
Set nwo = CreateObject("WScript.Network")
comp = LCase(nwo.ComputerName)

'��������� ��� ���������� ����������
If Not SILENT Then
	comp = InputBox("������� ��� ����������:", TITLE, comp)
	'��������� ����������� ����������
	If Len(comp) > 0 And Unavailable(comp) Then
		MsgBox "��������� ����������:" & vbCrLf & comp, vbExclamation, TITLE
		comp = ""
	End If
End If

'�������� ��������������
If Len(comp) > 0 Then InventSoft

'���� ������
If Len(Err.Description) > 0 Then _
	If Not SILENT Then MsgBox comp & vbCrLf & "������:" & vbCrLf & Err.Description, vbExclamation, TITLE

'== ������������

'��������� � WMI ��������� � ������������, ����� ����� ���� ��������� ���������� ��������� ������
Sub InventSoft

	'���������� ������ ���������� ���������� ����� WMI
	Set wmio = GetObject("WinMgmts:{impersonationLevel=impersonate}!\\" & comp & "\Root\default:StdRegProv")

	'������� ���� ������
	Dim fso, tf
	Set fso = CreateObject("Scripting.FileSystemObject")
	If Not fso.FolderExists(DATA_DIR) Then
		If Not SILENT Then MsgBox "�� ������ ������� ��� ���������� ������:" & vbCrLf & DATA_DIR, vbExclamation, TITLE
		Exit Sub
	End If
	Set tf = fso.CreateTextFile(DATA_DIR & comp & DATA_EXT, True)

	'�������� ��������� ��������
	If HEAD_LINE Then tf.WriteLine "�������� � ������;�������������;���� ���������"

	'������ ��������� � �������� ����� ��� ������
	Dim s
	s = ExtractSoft("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\")
	If Len(s) > 0 Then tf.Write s

	'��� 64-������ ������ ���� ��� ������ ����! (32-������ ��������� �� 64-������ �������)
	s = ExtractSoft("SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\")
	If Len(s) > 0 Then tf.Write s

	'������� ���� ������
	tf.Close
	If Not SILENT Then MsgBox "����� �������� � ����:" & vbCrLf & DATA_DIR & comp & DATA_EXT, vbInformation, TITLE

End Sub

'��������� ��������� ���� �������; ������� ������ ��� ������ � ���� ������
Function ExtractSoft(key)

	'�������� ���������
	Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE
	Dim items
	wmio.EnumKey HKLM, key, items
	If IsNull(items) Then
		ExtractSoft = ""
		Exit Function
	End If

	'�������� ������ ��������
	Dim s, item, ok, name, publ, inst, x, prev
	s = "" '��������� ����������� � ������
	For Each item In items

		ok = True '���� �����������

		'��������, ���������� ������ � �������������
		prev = name
		wmio.GetStringValue HKLM, key & item, "DisplayName", name
		If IsNull(name) Or Len(name) = 0 Or name = prev Then
			ok = False
		Else '�� ��������� ������ ";"
			name = Replace(name, ";", "_")
		End If

		'�������� ��������, �� �������� ��������� ParentKeyName = "OperatingSystem"
		If ok Then
			wmio.GetStringValue HKLM, key & item, "ParentKeyName", x
			'��� ��������
			If UPDATES Then
				If IsNull(x) Or x <> "OperatingSystem" Then ok = False
			'��� ����������
			Else
				If Not IsNull(x) And x = "OperatingSystem" Then ok = False
			End If
		End If

		'���� ���������
		If ok Then
			wmio.GetStringValue HKLM, key & item, "InstallDate", inst
			If IsNull(inst) Or Len(inst) < 8 Then
				inst = "-"
			Else '������������� � �������� ���
				inst = Mid(inst, 7, 2) & "." & Mid(inst, 5, 2) & "." & Left(inst, 4)
			End If
		End If

		'�������������
		If ok Then
			wmio.GetStringValue HKLM, key & item, "Publisher", publ
			If IsNull(publ) Or Len(publ) = 0 Then publ = "-"
		End If

		If ok Then s = s & name & ";" & publ & ";" & inst & vbCrLf

	Next
	ExtractSoft = s

End Function

'��������� ����������� ���������� � ����; ������� True, ���� ����� ����������
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