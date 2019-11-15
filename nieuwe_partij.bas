B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region

Sub Process_Globals
	Dim clsDbe As clsDb
	Dim curs As Cursor
	Dim spr_list As List
	Dim discip As String
	Dim beurten, caroms As Int
End Sub

Sub Globals
	Private spr_discipline As Spinner
	
	Private txt_caroms As EditText
	Private txt_caroms_tegen As EditText
	Private txt_beurten As EditText
	Private txt_moyenne As EditText
	Private txt_tegen As EditText
	Private txt_moyenne_tegen As EditText
	Private txt_locatie As EditText
	Private btn_save As Button
End Sub


Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("nieuwe_partij")
	clsDbe.Initialize
	getDisciplines
	txt_locatie.RequestFocus
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub getDisciplines
	curs = clsDbe.retDisciplines
	spr_list.Initialize
	
	For i = 0 To curs.RowCount -1
		curs.Position = i
		spr_discipline.Add(curs.GetString("discipline"))
		spr_list.Add(curs.GetString("id"))
	Next
		
	discip = spr_list.Get(0)
	clsDbe.closeConnection
	curs.Close
End Sub


Sub spr_discipline_ItemClick (Position As Int, Value As Object)
	Log(spr_list.Get(Position))
End Sub


Sub txt_caroms_tegen_TextChanged (Old As String, New As String)
	checkBeurten
	calcMoyenneTegen
End Sub

Sub txt_caroms_TextChanged (Old As String, New As String)
	checkBeurten
	calcMoyenne
End Sub

Sub txt_beurten_TextChanged (Old As String, New As String)
	If txt_beurten.Text = "" Then Return
	calcMoyenne
	calcMoyenneTegen
End Sub

Sub checkBeurten
	If txt_beurten.Text = "" Then
		ToastMessageShow("Er zijn nog geen beurten opgegeven", False)
		txt_beurten.RequestFocus
		Return
	End If
End Sub

Sub calcMoyenne
	If txt_caroms.Text = "" Then Return
	beurten = txt_beurten.Text
	caroms = txt_caroms.Text
	txt_moyenne.Text = NumberFormat2((caroms/beurten),1,3,3,False)
End Sub

Sub calcMoyenneTegen
	If txt_caroms_tegen.Text = "" Then Return
	beurten = txt_beurten.Text
	caroms = txt_caroms_tegen.Text
	txt_moyenne_tegen.Text = NumberFormat2((caroms/beurten),1,3,3,False)
End Sub

Sub txt_caroms_FocusChanged (HasFocus As Boolean)
	checkBeurten
End Sub

Sub txt_caroms_tegen_FocusChanged (HasFocus As Boolean)
	checkBeurten
End Sub

Sub btn_save_Click
	
End Sub