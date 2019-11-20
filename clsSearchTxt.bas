B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
#IgnoreWarnings: 12

Sub Class_Globals
	Dim txtLocations As String = "location.txt"
	Dim txtOpponent As String = "opponent.txt"
	Dim share As String = Starter.share
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub isInLocations(txt As String)
	Dim readFile As String
	
	readFile = File.ReadString(share, txtLocations)
	If readFile.IndexOf(txt) = -1 Then
		File.WriteString(share, txtLocations,$"${readFile}${txt}${CRLF}"$)
	End If
End Sub

Sub isInOpponent(txt As String)
	Dim readFile As String
	
	readFile = File.ReadString(share, txtOpponent)
	If readFile.IndexOf(txt) = -1 Then
		File.WriteString(share, txtOpponent,$"${readFile}${txt}${CRLF}"$)
	End If
End Sub

Sub createLocList As List
'	Dim lst As List 
'	lst.Initialize
'	= File.ReadList(share, txtLocations)
	Return File.ReadList(share, txtLocations)
End Sub
