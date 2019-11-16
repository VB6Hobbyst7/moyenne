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
	Private curs As Cursor
	Private clsDbe As clsDb
	Private spr_list As List
	Private totMoyenne As Float
	Private totaal As Int
End Sub

Sub Globals
	Private discip As String

	Private lbl_add As Label
	Private lbl_partijen_found As Label
	Private clv_partijen As CustomListView
	Private lbl_beurten As Label
	Private lbl_carom As Label
	Private lbl_carom_opponent As Label
	Private lbl_locatie As Label
	Private lbl_moyenne As Label
	Private lbl_moyenne_opponent As Label
	Private lbl_tegen As Label
	Private pnl_partij As Panel
	Private lbl_datum As Label
	Private spr_discipline As Spinner
	
	Private lbl_discipline_moyenne As Label
	Private lbl_delete As Label
	Private spr_year As Spinner
	Private lbl_chart As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("partij_lijst")
	clsDbe.Initialize
	getDisciplines
	getYears
	createPartijList
	countPartijen
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub lbl_add_Click
	StartActivity(nieuwe_partij)
End Sub

Sub countPartijen
	lbl_partijen_found.Text = $"Gespeelde partijen"$
End Sub

Sub createPartijList
	totMoyenne = 0
	totaal = 0
	DateTime.DateFormat ="dd-MMMM-yyyy"
	curs = clsDbe.retPartijen(discip, spr_year.SelectedItem)
	clv_partijen.Clear
	For i = 0 To curs.RowCount -1
		curs.Position = i
		clv_partijen.Add(genPartij(curs.GetString("location"), curs.GetString("beurten"), curs.GetString("caroms"), curs.GetString("moyenne"), curs.GetString("opponent"), curs.GetString("caroms_opponent"), curs.GetString("moyenne_opponent"), curs.GetLong("date_time"), curs.GetLong("id"), clv_partijen.AsView.Width), "")
	Next
	
	If totMoyenne > 0 And totaal > 0 Then
		lbl_discipline_moyenne.Text = "Discipline gemiddelde : " & NumberFormat2(totMoyenne/totaal,1,3,3,False)
	Else 	
		lbl_discipline_moyenne.Text = "Discipline gemiddelde : 0.000"
	End If
	curs.Close
	clsDbe.closeConnection
End Sub

Sub genPartij(location As String, beurten As String, caroms As String, moyenne As String, tegen As String, caroms_opponent As String, moyenne_opponent As String, date As Long, id As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 245dip)
	p.LoadLayout("clv_partijen")
	p.Tag = id
	
	lbl_locatie.Text = location
	lbl_beurten.Text = beurten
	lbl_carom.Text = caroms
	lbl_moyenne.Text = NumberFormat2(moyenne,1,3,3,False)
	lbl_tegen.Text = tegen
	lbl_carom_opponent.Text = caroms_opponent
	lbl_moyenne_opponent.Text = NumberFormat2(moyenne_opponent,1,3,3,False)
	lbl_datum.Text = DateTime.Date(date)
	totMoyenne = totMoyenne+moyenne
	totaal = totaal + 1
	Return p
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


Sub getYears
	curs = clsDbe.UniqueYears
	If curs.RowCount < 1 Then
		spr_year.Add(DateTime.GetYear(DateTime.Now))
		Return
	End If
	
	For i = 0 To curs.RowCount -1
		curs.Position = i
		spr_year.Add(curs.GetString("year"))
	Next
	clsDbe.closeConnection
	curs.Close
	
End Sub

Sub spr_discipline_ItemClick (Position As Int, Value As Object)
	discip = spr_list.Get(Position)
	createPartijList
End Sub

Sub clv_partijen_ItemClick (Index As Int, Value As Object)
	Return
End Sub

Sub lbl_delete_Click
	
End Sub

Sub spr_year_ItemClick (Position As Int, Value As Object)
	createPartijList
End Sub

Sub lbl_chart_Click
	Starter.yearForChart = spr_year.SelectedItem
	Starter.disciplineForChart = spr_list.Get(spr_discipline.SelectedIndex)
	Starter.disciplineName = spr_discipline.SelectedItem
	StartActivity(partij_chart)
End Sub