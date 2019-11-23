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
	Private curs As Cursor
	Private clsDbe As clsDb
	Private clsFunc As clsFunctions
	Private spr_list As List
	Private totMoyenne As Float
	Private totaal As Int
'	Private discipline_id As String
End Sub

Sub Globals
	Private discip As String
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
	Private lbl_edit As Label
	Private toolbar As ACToolBarDark
	Private NavDrawer As DSNavigationDrawer
	Private lbl_tot_partijen As Label
	Private lbl_tot_hoogste_serie As Label
	Private lbl_tot_caromboles As Label
	Private lbl_tot_gem_caromboles As Label
	Private lbl_tot_moyenne As Label
	Private lbl_tot_laatste_partij As Label
	Private lbl_win As Label
	Private lbl_tot_gewonnen As Label
	Private lbl_tot_verloren As Label
	Private lbl_app_name As Label
	Private lbl_version As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("partij_lijst")
	
	clsDbe.Initialize
	clsFunc.Initialize
	lbl_version.Initialize("")
	lbl_app_name.Initialize("")
	lbl_app_name.Text = Application.LabelName
	lbl_version.Text = Application.VersionName
	setupNavigation
'	getDisciplines
'	getYears
'	createPartijList
'	countPartijen
	Wait For(initiateData) Complete(result As Boolean)
	lbl_version.Text = $"Versie ${Application.VersionName}"$
End Sub


	
Sub initiateData As ResumableSub
	getDisciplines
	getYears
	createPartijList
	countPartijen
	Return True
	
End Sub
	
	
Sub setupNavigation
	NavDrawer.Initialize2("NavDrawer", Activity, NavDrawer.DefaultDrawerWidth, NavDrawer.GRAVITY_START)
	NavDrawer.InitDrawerToggle
	NavDrawer.NavigationView.LoadLayout("slidingMenu", NavDrawer.DefaultHeaderHeight)
	NavDrawer.NavigationView.Menu.Add(1, 1000, "Disciplines bewerken", genCode.FontBit(Chr(0xE3C9), 28, Colors.Green, False))
	NavDrawer.NavigationView.Menu.Add(2, 1001, "Nieuwe partij", genCode.FontBit(Chr(0xE148), 28, Colors.Black, False))
	NavDrawer.NavigationView.Menu.Add(3, 1002, "Moyenne grafiek", genCode.FontBit(Chr(0xE922), 28, Colors.Black, False))
	NavDrawer.NavigationView.Menu.Add(4, 1005, "Backup data", genCode.FontBit(Chr(0xE2C2), 28, Colors.Black, False))
	NavDrawer.NavigationView.Menu.Add(5, 1006, "Data terug zetten", genCode.FontBit(Chr(0xE8B3), 28, Colors.Black, False))

	NavDrawer.NavigationView.SetItemTextColors(Colors.Gray, Colors.Black, Colors.Red, Colors.LightGray)
	
	
End Sub

Sub toolbar_NavigationItemClick
	If NavDrawer.IsDrawerOpen Then
		NavDrawer.CloseDrawer
	Else
		lbl_app_name.Text = Application.LabelName
		lbl_version.Text = $"Versie ${Application.VersionName}"$
		NavDrawer.OpenDrawer
	
	End If
End Sub

Sub NavDrawer_DrawerOpened (DrawerGravity As Int)
	lbl_version.Text = $"Versie ${Application.VersionName}"$
End Sub

Sub Activity_Resume
	Dim lastIndex As Int = Starter.partijenIndex
	
	countPartijen
	If Starter.partijDisciplineChanged = True Then
		clv_partijen.RemoveAt(lastIndex)
		MsgboxAsync($"Partij is terug te vinden onder ${Starter.partijNewDiscipline}"$, "Mijn moyenne")
		Starter.partijDisciplineChanged = False
		Starter.partijNewDiscipline = ""
		Return
	End If
	
	If Starter.partijLastId <> "" Then
		clsDbe.retrieveGameData(Starter.partijLastId)
		clsDbe.curs.Position = 0
		clv_partijen.Add(genPartij(clsDbe.curs.GetString("location"), clsDbe.curs.GetString("beurten"), clsDbe.curs.GetString("caroms"), clsDbe.curs.GetString("moyenne"), clsDbe.curs.GetString("opponent"), clsDbe.curs.GetString("caroms_opponent"), clsDbe.curs.GetString("moyenne_opponent"), clsDbe.curs.GetLong("date_time"), clsDbe.curs.GetString("id"), clv_partijen.AsView.Width), "")
		clsDbe.closeConnection
		Starter.partijLastId = ""
	End If
	
	If lastIndex > -1 Then
		updatePartij
		clsFunc.colorHeaderNew(clv_partijen, lastIndex, -1)
		clv_partijen.AsView.ScrollViewOffsetX = Starter.partijenOffset
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub updatePartij
	Dim pnl As Panel = clv_partijen.GetPanel(Starter.partijenIndex)
	Dim lbl As Label
	Dim year, disciplineId, avg As String
	
	lbl.Initialize("")
	clsDbe.retrieveGameData(pnl.Tag)
	clsDbe.curs.Position = 0
	year = clsDbe.curs.GetString("year")
	disciplineId = clsDbe.curs.GetString("discipline_id")
	
	For Each v As View In pnl.GetAllViewsRecursive
		If v.Tag = "lbl_locatie" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("location")
		End If
		
		If v.Tag = "lbl_datum" Then
			lbl = v
			lbl.Text = DateTime.Date(clsDbe.curs.GetLong("date_time"))
		End If
		
		If v.Tag = "lbl_beurten" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("beurten")
		End If
		
		If v.Tag = "lbl_carom" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("caroms")
		End If
		
		If v.Tag = "lbl_moyenne" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("moyenne")
		End If
		
		If v.Tag = "lbl_tegen" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("opponent")
		End If
		
		If v.Tag = "lbl_carom_opponent" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("caroms_opponent")
		End If
		
		If v.Tag = "lbl_moyenne_opponent" Then
			lbl = v
			lbl.Text = clsDbe.curs.GetString("moyenne_opponent")
		End If
		
		If v.Tag = "lbl_win" Then
			lbl = v
			If clsDbe.curs.GetInt("tafel_groot") > 0 Then
				lbl.Visible = True
			Else 	
				lbl.Visible = False
			End If
		End If
	Next
	clsDbe.closeConnection
	
	clsDbe.genDisciplineAvg(disciplineId, year)
	clsDbe.curs.Position = 0
	
	avg = NumberFormat2(clsDbe.curs.GetDouble("avg_gem"),1, 3, 3, False)
	
	lbl_discipline_moyenne.Text = $"Discipline gemiddelde : ${avg}"$
	clsDbe.closeConnection
End Sub

Sub lbl_add_Click
	StartActivity(nieuwe_partij)
End Sub

Sub countPartijen
	clsDbe.partijSummary(discip)
	If clsDbe.curs.RowCount > 0 Then
		clsDbe.curs.Position = 0
		lbl_tot_partijen.Text = "Partijen : " & clsDbe.curs.GetString("tot_games")
		lbl_tot_hoogste_serie.Text = "Hoogste serie : " &clsDbe.curs.GetString("hoogste_serie")
		lbl_tot_caromboles.Text = "Caromboles : "&clsDbe.curs.GetString("tot_car")
		lbl_tot_gem_caromboles.Text = "Gemiddeld : "&NumberFormat2(clsDbe.curs.GetDouble("avg_car"), 1,3,3,False)
		lbl_tot_moyenne.Text = "Moyenne : "&NumberFormat2(clsDbe.curs.GetDouble("moy"), 1,3,3,False)
		lbl_tot_laatste_partij.Text = "Laatste Partij : "&DateTime.Date(clsDbe.curs.GetLong("date_time"))
		lbl_tot_gewonnen.Text = "Gewonnen : " & clsDbe.curs.GetString("winst")
		lbl_tot_verloren.Text = "Verloren : " & clsDbe.curs.GetString("verlies")
	Else
		lbl_tot_partijen.Text = "Partijen : 0"
		lbl_tot_hoogste_serie.Text = "Hoogste serie : 0"
		lbl_tot_caromboles.Text = "Caromboles : 0"
		lbl_tot_gem_caromboles.Text = "Gemiddeld : 0.00"
		lbl_tot_moyenne.Text = "Moyenne : 0.00"
		lbl_tot_laatste_partij.Text = "Laatste Partij : "
		lbl_tot_gewonnen.Text = "Gewonnen : 0"
		lbl_tot_verloren.Text = "Verloren : 0"
	End If
	clsDbe.closeConnection
End Sub

Sub createPartijList
	Dim viewWidth As Int = clv_partijen.AsView.Width
	
	totMoyenne = 0
	totaal = 0
	
	Dim curs As Cursor = clsDbe.retPartijen(discip, spr_year.SelectedItem)
	
	clv_partijen.Clear
	
	For i = 0 To clsDbe.curs.RowCount -1
		curs.Position = i
		If curs.GetString("moyenne") = "" Then
			Continue
		End If
		clv_partijen.Add(genPartij(curs.GetString("location"), curs.GetString("beurten"), curs.GetString("caroms"), curs.GetString("moyenne"), curs.GetString("opponent"), curs.GetString("caroms_opponent"), clsDbe.curs.GetString("moyenne_opponent"), clsDbe.curs.GetLong("date_time"), clsDbe.curs.GetString("id"), viewWidth), "")
	Next
	
	If totMoyenne > 0 And totaal > 0 Then
		lbl_discipline_moyenne.Text = "Discipline gemiddelde : " & NumberFormat2(totMoyenne/totaal,1,3,3,False)
	Else 	
		lbl_discipline_moyenne.Text = "Discipline gemiddelde : 0.000"
	End If
	curs.Close
	'clsDbe.closeConnection
End Sub

Sub genPartij(location As String, beurten As String, caroms As String, moyenne As String, tegen As String, caroms_opponent As String, moyenne_opponent As String, date As Long, id As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 220dip)
	'p.SetLayoutAnimated(1300,0,0, width, 220dip)
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
	If clsDbe.curs.GetLong("tafel_groot") <> 1 Then
		lbl_win.Visible = False
	Else 
		lbl_win.Visible = True
	End If
 	totMoyenne = totMoyenne+moyenne
	totaal = totaal + 1
	Return p
End Sub

Sub getDisciplines
	curs = clsDbe.retDisciplines
	spr_list.Initialize
	spr_list.Clear
	spr_discipline.Clear
	
	For i = 0 To curs.RowCount -1
		curs.Position = i
		spr_discipline.Add(curs.GetString("discipline"))
		spr_list.Add(curs.GetString("id"))
	Next
		
	discip = spr_list.Get(0)
	Starter.disciplineId = discip
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
'	discipline_id = spr_list.Get(Position)
	Starter.disciplineId = spr_list.Get(Position)
	createPartijList
	countPartijen
End Sub

Sub clv_partijen_ItemClick (Index As Int, Value As Object)
	Return
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

Sub lbl_delete_Click
	Dim index As String =clsFunc.colorHeader(clv_partijen, Sender)
	Dim pnl As Panel = clv_partijen.GetPanel(index)
	Dim id As  String = pnl.Tag
	
	Msgbox2Async($"Geselecteerde partij verwijderen?"$, Application.LabelName, "Ja", "", "Nee", Null, False)
	
	Wait For Msgbox_Result (response As Int)
	
	If response = DialogResponse.POSITIVE Then
		clsDbe.deletePartij(id)
		clv_partijen.RemoveAt(index)
		clsDbe.closeConnection
		countPartijen
	End If
	
End Sub

Sub lbl_edit_Click
	Dim index As String =clsFunc.colorHeader(clv_partijen, Sender)
	Dim pnl As Panel = clv_partijen.GetPanel(index)
	Dim id As  String = pnl.Tag
	Starter.game_id = id
	Starter.partijenIndex = index
	Starter.partijSender = Sender
	Starter.partijDisciplineChanged = False
	Starter.disciplineName = spr_discipline.SelectedItem
	StartActivity(nieuwe_partij)
	
End Sub

Sub pnl_partij_Click
	Dim index As Int = clv_partijen.GetItemFromView(Sender)
	clsFunc.colorHeaderNew(clv_partijen, index, Starter.partijenIndex)
	
	
	Starter.partijenIndex = index
	Starter.partijSender = Sender
End Sub

Sub lbl_disci_Click
	StartActivity(discipline)
End Sub

Sub clv_partijen_ScrollChanged (Offset As Int)
	Starter.partijenOffset = Offset
End Sub

Sub lbl_partijen_found_Click
	clsFunc.restoreData
End Sub

Sub toolbar_NavigationItemClick1
	
End Sub

Sub NavDrawer_NavigationItemSelected (MenuItem As ACMenuItem, DrawerGravity As Int)
	
	Select MenuItem.Id
		Case 1
			StartActivity(discipline)
		Case 2
			StartActivity(nieuwe_partij)
		Case 3
			Starter.yearForChart = spr_year.SelectedItem
			Starter.disciplineForChart = spr_list.Get(spr_discipline.SelectedIndex)
			Starter.disciplineName = spr_discipline.SelectedItem
			StartActivity(partij_chart)
		Case 4
			clsFunc.backupData
		Case 5
			clsFunc.restoreData	
	End Select
	NavDrawer.CloseDrawer
End Sub


Sub addPartijLabel_Click
	
End Sub


Sub Activity_CreateMenu(Menu As ACMenu)
	Dim item As ACMenuItem = toolbar.Menu.Add2(1, 0, "addPartij",  Null)
	item.Icon = clsFunc.BitmapToBitmapDrawable( clsFunc.FontAwesomeToBitmap(Chr(0xF196), 28))
	item.ShowAsAction = item.SHOW_AS_ACTION_ALWAYS
	toolbar.InitMenuListener
End Sub

Sub toolbar_MenuItemClick (Item As ACMenuItem)
	Select Item.Id
		Case 1
			StartActivity(nieuwe_partij)
	End Select
End Sub

#If Java

public boolean _onCreateOptionsMenu(android.view.Menu menu) {
    if (processBA.subExists("activity_createmenu")) {
        processBA.raiseEvent2(null, true, "activity_createmenu", false, new de.amberhome.objects.appcompat.ACMenuWrapper(menu));
        return true;
    }
    else
        return false;
}
#End If