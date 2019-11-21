B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
	#IgnoreWarnings: 12
#End Region
#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	Private curs As Cursor
End Sub


Sub Globals
	Private ime As IME
	Private pnl_discipline As Panel
	Private lbl_discipline_header As Label
	Private clsdbe As clsDb
	Private clsFunc As clsFunctions
	Private clv_discipline As CustomListView
	Private lbl_delete As Label
	Private DetailsDialog As CustomLayoutDialog
	Private txt_discipline_edit As B4XView
	Private lbl_edit As Label
	
	Private chk_default As CheckBox
	Private toolbar As ACToolBarDark
End Sub


Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("discipline")
	clsdbe.Initialize
	clsFunc.Initialize
	
	ime.Initialize("")
	createDisciplineList
	
End Sub


Sub Activity_Resume

End Sub


Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub txt_discipline_FocusChanged (HasFocus As Boolean)
	
End Sub


Sub createDisciplineList
	curs = Starter.clsDbe.lstDisciplines
	clsdbe.closeConnection
	clv_discipline.Clear
	curs.Position = 0

	For i = 0 To curs.RowCount - 1
		curs.Position = i
		clv_discipline.Add(genDisciplineList(curs.GetString("discipline"), curs.GetString("id"), clv_discipline.AsView.Width, curs.GetString("is_default")), "")
	Next
	curs.Close
	countDisciplines
End Sub


Sub genDisciplineList(disci As String, id As String, width As Int, isDefault As String) As Panel
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 100dip)
	
	p.LoadLayout("clv_discipline")
	lbl_discipline_header.Text = disci
	lbl_discipline_header.Tag = "disci"
	If isDefault = "1" Then
		chk_default.Checked = True
	End If
	p.Tag = id
	Return p
End Sub


Sub lbl_discipline_header_Click
	Dim index As Int = clv_discipline.GetItemFromView(Sender)
	clsFunc.colorHeaderNew(clv_discipline, index, Starter.disciplineIndex)
	Starter.disciplineIndex = index
	
End Sub


Sub lbl_edit_Click
	Dim index As Int =clsFunc.colorHeader(clv_discipline, Sender)
	Dim pnl As Panel = clv_discipline.GetPanel(index)
	Dim id As  String = pnl.Tag
	Dim label As Label
	
	For Each lbl As View In pnl.GetAllViewsRecursive
		If lbl.Tag = "disci" Then
			label = lbl
			Exit
		End If
	Next
	addEdit(True, label, id)
	
	
End Sub


Sub pnl_discipline_Click
	Dim index As Int = clv_discipline.GetItemFromView(Sender)
	clsFunc.colorHeaderNew(clv_discipline, index, Starter.disciplineIndex)
	Starter.disciplineIndex = index
End Sub


Sub lbl_delete_Click
	Dim index As String = clsFunc.colorHeader(clv_discipline, Sender)
	Dim pnl As Panel = clv_discipline.GetPanel(index)
	Dim partijCount As Int
	Dim zijnIs As String
	
	clsdbe.RetrieveDisciplinePartijen(pnl.Tag)
	clsdbe.curs.Position = 0
	partijCount = clsdbe.curs.GetInt("count")
	
	If partijCount > 1 Then
		zijnIs = $"zijn ${partijCount} partijen"$
	Else
		zijnIs = $"is ${partijCount} partij"$
	End If
	
	If partijCount > 0 Then
		Msgbox2Async($"Kan discipline niet verwijderen er ${zijnIs} aangemaakt onder deze discipline"$, Application.LabelName, "Oke", "", "", Null, False)
		clsdbe.closeConnection
		Return
	Else
		clsdbe.closeConnection
	End If
	
	Msgbox2Async($"Geselecteerde discipline verwijderen?"$, Application.LabelName, "Ja", "", "Nee", Null, False)
	
	Wait For Msgbox_Result (response As Int)
	
	If response = DialogResponse.POSITIVE Then
		removeItem(index)
	End If
	countDisciplines
End Sub


Sub removeItem(index As String)
	Dim pnl As Panel = clv_discipline.GetPanel(index)
	Dim id As String = pnl.Tag
	
	clsdbe.deleteDiscipline(id)
	clsdbe.closeConnection
	clv_discipline.RemoveAt(index)
End Sub


Sub addEdit(edit As Boolean, label As Label, id As String)
	
	Dim sf As Object = DetailsDialog.ShowAsync("", "Bewaar", "Annuleer", "", Null, True)
	DetailsDialog.SetSize(100%X, 250dip)
	Wait For (sf) Dialog_Ready(pnl As Panel)
	pnl.LoadLayout("discipline_edit")
	txt_discipline_edit.Text = label.Text
	txt_discipline_edit.Enabled = True
	If edit = False Then
		'txt_discipline_edit.Hint 
		txt_discipline_edit.EditTextHint= "Nieuwe discipline"
	End If
	txt_discipline_edit.RequestFocus
	Wait For (sf) Dialog_Result(result As Int)
	
	If result = DialogResponse.POSITIVE Then
		label.Text = txt_discipline_edit.Text
		If edit = False Then
			id = ""
		End If
		clsdbe.addDiscipline(txt_discipline_edit.Text, id)
		If edit = False Then
			createDisciplineList
		End If
	End If
	ime.HideKeyboard
	countDisciplines
End Sub

Sub countDisciplines
'	lbl_disciplines_found.Text = $"Disciplines (${clv_discipline.Size})"$
End Sub

Sub lbl_add_Click
	
	Dim label As Label
	label.Initialize("")
	addEdit(False, label, "")
End Sub

Sub setHeaderColor
	Dim index As Int = clv_discipline.GetItemFromView(Sender)
	clsFunc.colorHeaderNew(clv_discipline, index, Starter.disciplineIndex)
End Sub

'GET/SET DEFAULT DISCIPLINE
Sub chk_default_Click()'CheckedChange(Checked As Boolean)
	Dim index As Int = clv_discipline.GetItemFromView(Sender)
	Dim pnl As Panel
	'Dim chk As CheckBox
	
	pnl = clv_discipline.GetPanel(index)
	For Each v As View In pnl.GetAllViewsRecursive
		If v Is CheckBox Then
			Dim chk As CheckBox
			chk = v
			clsdbe.uncheckDiscipline(pnl.Tag, 1)
			clsdbe.closeConnection
			
		End If
	Next
	
	For i = 0 To clv_discipline.Size - 1
		pnl = clv_discipline.GetPanel(i)
		For Each v As View In pnl.GetAllViewsRecursive
			If v Is CheckBox Then
				Dim chk As CheckBox
				chk = v
				If chk.Checked And i <> index Then
					chk.Checked= False
					clsdbe.uncheckDiscipline(pnl.Tag, 0)
					clsdbe.closeConnection
					Exit
				End If
			End If
		Next
	Next

End Sub

Sub Activity_CreateMenu(Menu As ACMenu)
	Dim item As ACMenuItem = toolbar.Menu.Add2(1, 0, "addDiscipline",  Null)
	item.Icon = clsFunc.BitmapToBitmapDrawable( clsFunc.FontAwesomeToBitmap(Chr(0xF196), 28))
	item.ShowAsAction = item.SHOW_AS_ACTION_ALWAYS
	toolbar.InitMenuListener
End Sub

Sub toolbar_MenuItemClick (Item As ACMenuItem)
	Select Item.Id
		Case 1
			Dim label As Label
			label.Initialize("")
			addEdit(False, label, "")
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
