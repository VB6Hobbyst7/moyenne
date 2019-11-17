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
	Dim date As Long
	
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
	Private lbl_date As Label
	Private txt_date As EditText
	Private chk_groot As CheckBox
End Sub


Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("nieuwe_partij")
	clsDbe.Initialize
	getDisciplines
	If Starter.game_id <> "" Then
		setGameData
	End If
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	Starter. game_id = ""
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
	discip = spr_list.Get(Position)
End Sub

Sub retDiscipId As String
	Return discip
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
	Dim groot As Int
	
	If chk_groot.Checked = True Then
		groot = 1
	Else
		groot = 0	
	End If
	
	If Starter.game_id = "" Then
		clsDbe.addPartij(txt_locatie.Text, txt_beurten.Text, txt_caroms.Text, txt_moyenne.Text, txt_tegen.Text, txt_caroms_tegen.Text, txt_moyenne_tegen.Text, txt_date.Tag)
	Else
		clsDbe.updatePartij(txt_locatie.Text, txt_beurten.Text, txt_caroms.Text, txt_moyenne.Text, txt_tegen.Text, txt_caroms_tegen.Text, txt_moyenne_tegen.Text, date,groot)
		ToastMessageShow("Partij opgeslagen", False)
		Activity.Finish
	End If
End Sub

Sub lbl_date_Click
	Dim newDate As DateDialog
	Dim result As Int
	DateTime.DateFormat = "dd-MM-yyyy"
	
	If date > 0 Then
		newDate.DateTicks = date
	Else
		newDate.SetDate(DateTime.GetDayOfMonth(DateTime.Now), DateTime.GetMonth(DateTime.Now), DateTime.GetYear(DateTime.Now))
	End If
	
	
	result	= newDate.Show("Selecteer een datum" &CRLF, "Mijn moyenne", "Oke", "","Annuleer", Null)
	
	
	If result = DialogResponse.POSITIVE Then
		txt_date.Text 	= DateTime.Date(newDate.DateTicks)
		txt_date.Tag	= newDate.DateTicks
		date = newDate.DateTicks
	End If
	
End Sub


Sub setGameData
	DateTime.DateFormat = "dd-MM-yyyy"
	clsDbe.retrieveGameData(Starter.game_id)
	clsDbe.curs.Position = 0
	
	
	txt_date.Text =  DateTime.Date(clsDbe.curs.GetLong("date_time"))
	txt_date.Tag = clsDbe.curs.GetLong("date_time")
	date = clsDbe.curs.GetLong("date_time")
	spr_discipline.SelectedIndex =  spr_list.IndexOf(clsDbe.curs.GetString("discipline_id"))
	txt_locatie.Text = clsDbe.curs.GetString("location")
	txt_beurten.Text = 	clsDbe.curs.GetString("beurten")
	txt_caroms.Text = clsDbe.curs.GetString("caroms")
	txt_moyenne.Text = clsDbe.curs.GetString("moyenne")
	txt_tegen.Text = clsDbe.curs.GetString("opponent")
	txt_caroms_tegen.Text = clsDbe.curs.GetString("caroms_opponent")
	txt_moyenne_tegen.Text = clsDbe.curs.GetString("moyenne_opponent")
	discip = clsDbe.curs.GetString("discipline_id")
	
	clsDbe.closeConnection
End Sub


