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

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

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
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("partij_lijst")
	clsDbe.Initialize
	createPartijList
	countPartijen
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub lbl_add_Click
	createPartijList
End Sub

Sub countPartijen
	lbl_partijen_found.Text = $"Gespeelde partijen"$
End Sub

Sub createPartijList
	DateTime.DateFormat ="dd-MMMM-yyyy"
	curs = clsDbe.retPartijen
	clv_partijen.Clear
	For i = 0 To curs.RowCount -1
		curs.Position = i
		clv_partijen.Add(genPartij(curs.GetString("location"), curs.GetString("beurten"), curs.GetString("caroms"), curs.GetString("moyenne"), curs.GetString("opponent"), curs.GetString("caroms_opponent"), curs.GetString("moyenne_opponent"), curs.GetLong("date_time"), clv_partijen.AsView.Width), "")
	Next
	curs.Close
	clsDbe.closeConnection
End Sub

Sub genPartij(location As String, beurten As String, caroms As String, moyenne As String, tegen As String, caroms_opponent As String, moyenne_opponent As String, date As Long, width As Int) As Panel
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 245dip)
	p.LoadLayout("clv_partijen")
	
	lbl_locatie.Text = location
	lbl_beurten.Text = beurten
	lbl_carom.Text = caroms
	lbl_moyenne.Text = NumberFormat2(moyenne,1,3,3,False)
	lbl_tegen.Text = tegen
	lbl_carom_opponent.Text = caroms_opponent
	lbl_moyenne_opponent.Text = NumberFormat2(moyenne_opponent,1,3,3,False)
	lbl_datum.Text = DateTime.Date(date)
	
	Return p	
End Sub



