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
#Extends: android.support.v7.app.AppCompatActivity
Sub Process_Globals
	Dim clsDbe As clsDb
	Dim clsFunc As clsFunctions
	Dim curs As Cursor
	Dim spr_list As List
	Dim discip As String
	Dim beurten, caroms As Int
	Dim date As Long
	
End Sub

Sub Globals
	Dim ime As IME
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
	
	Private toolbar As ACToolBarDark
End Sub


Sub Activity_Create(FirstTime As Boolean)
	Dim time As Long = DateTime.Now
	clsDbe.Initialize
	clsFunc.Initialize
	Activity.LoadLayout("nieuwe_partij")
	
	ime.Initialize("ime")
	ime.AddHeightChangedEvent
	
	
	getDisciplines
	If Starter.game_id <> "" Then
		setGameData
		toolbar.SubTitle = "Partij bewerken"
	Else	
		toolbar.SubTitle = "Nieuwe partij"
	End If
	ime.ShowKeyboard(txt_locatie)
	txt_date.Text = $"$Date{time}"$
	txt_date.Tag = time
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

Sub validateInput As Boolean
	If txt_date.Text = "" Then
		txt_date.Hint = "Datum"
		txt_date.HintColor = Colors.red
		ime.ShowKeyboard(txt_date)
		Return False
	Else If txt_beurten.Text = "" Then
		txt_beurten.Hint = "Aantal beurten"
		txt_beurten.HintColor = Colors.Red
		ime.ShowKeyboard(txt_beurten)
		Return False
	Else If txt_caroms.Text = "" Then
		txt_caroms.Hint = "30"
		txt_caroms.HintColor = Colors.Red
		ime.ShowKeyboard(txt_caroms)
		Return False
	End If
	Return True
	
End Sub

Sub btn_save_Click
	If validateInput = False Then
		Return
	End If
	
	Dim groot As Int
	
	If chk_groot.Checked = True Then
		groot = 1
	Else
		groot = 0
	End If
	
	If Starter.game_id = "" Then
		clsDbe.addPartij(txt_locatie.Text, txt_beurten.Text, txt_caroms.Text, txt_moyenne.Text, txt_tegen.Text, txt_caroms_tegen.Text, txt_moyenne_tegen.Text, txt_date.Tag, groot)
		clsDbe.closeConnection
		Starter.partijLastId = clsDbe.lastInsertedId("partijen")
		clsDbe.closeConnection
		
		Msgbox2Async($"Nog een partij toevoegen?"$, Application.LabelName, "Ja", "", "Nee", Null, False)
	
		Wait For Msgbox_Result (response As Int)
	
		If response = DialogResponse.POSITIVE Then
			resetFields
			ime.ShowKeyboard(txt_locatie)
			Return
		End If
	Else
		clsDbe.updatePartij(txt_locatie.Text, txt_beurten.Text, txt_caroms.Text, txt_moyenne.Text, txt_tegen.Text, txt_caroms_tegen.Text, txt_moyenne_tegen.Text, date,groot)
		clsDbe.closeConnection
		ToastMessageShow("Partij opgeslagen", False)
		
		'DISCIPLINE CHANGED
		If spr_discipline.SelectedItem <> Starter.disciplineName Then
			Starter.partijDisciplineChanged = True
			Starter.partijNewDiscipline = spr_discipline.SelectedItem
		End If
		
	End If
	Activity.Finish
End Sub

Sub lbl_date_Click
	Dim newDate As DateDialog
	Dim result As Int
'	DateTime.DateFormat = "dd-MM-yyyy"
	
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
'	DateTime.DateFormat = "dd-MM-yyyy"
	clsDbe.retrieveGameData(Starter.game_id)
	clsDbe.curs.Position = 0
	If clsDbe.curs.GetLong("tafel_groot") = 1 Then
		chk_groot.Checked = True
	End If
	txt_date.Text =  DateTime.Date(clsDbe.curs.GetLong("date_time"))
	txt_date.Tag = clsDbe.curs.GetLong("date_time")
	date = clsDbe.curs.GetLong("date_time")
	spr_discipline.SelectedIndex =  spr_list.IndexOf(clsDbe.curs.GetString("discipline_id"))
	txt_locatie.Text = clsDbe.curs.GetString("location")
	txt_beurten.Text = 	clsDbe.curs.GetString("beurten")
	txt_caroms.Text = clsDbe.curs.GetString("caroms")
	txt_moyenne.Text = NumberFormat2(clsDbe.curs.GetString("moyenne"), 1,3,3,False)
	txt_tegen.Text = clsDbe.curs.GetString("opponent")
	txt_caroms_tegen.Text = clsDbe.curs.GetString("caroms_opponent")
	txt_moyenne_tegen.Text = NumberFormat2( clsDbe.curs.GetString("moyenne_opponent"),1,3,3,False)
	discip = clsDbe.curs.GetString("discipline_id")
	
	clsDbe.closeConnection
End Sub

Sub resetFields
	chk_groot.Checked = False
'	txt_date.Text =  ""
'	txt_date.Tag = DateTime.Date(DateTime.Now)
'	date = DateTime.Date(DateTime.Now)
	txt_locatie.Text = ""
	txt_beurten.Text = 	""
	txt_caroms.Text = ""
	txt_moyenne.Text = ""
	txt_tegen.Text = ""
	txt_caroms_tegen.Text = ""
	txt_moyenne_tegen.Text = ""
End Sub


