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


Sub Process_Globals
	Private disciId As String
	Private curs As Cursor
	Private oldValue As String
End Sub


Sub Globals
	Private ime As IME
	Private lbl_discipline As Label
	Private txt_discipline As EditText
	Private btn_save As Button
	Private pnl_discipline As Panel
	Private lbl_discipline_header As Label
	Private btn_new As ACButton
	Private clsdbe As clsDb
	Private clsFunc As clsFunctions
	Private clv_discipline As CustomListView
	Private lbl_delete As Label
	Private DetailsDialog As CustomLayoutDialog
	Private txt_discipline_edit As EditText
	Private lbl_edit As Label
	Private lbl_add As Label
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


Sub btn_save_Click
	clsdbe.addDiscipline(txt_discipline.Text, disciId)
	clsdbe.closeConnection
End Sub


Sub txt_discipline_FocusChanged (HasFocus As Boolean)
	
End Sub


Sub txt_discipline_TextChanged (Old As String, New As String)
	If Old.Length > 0 And oldValue = "" Then
		oldValue = Old	
	Else 
		Return	
	End If
	
	btn_new.Text = "Annuleer"
	If New.Length = 0 Then
		btn_save.Enabled = False
	Else
		btn_save.Enabled = Old <> New
	End If
End Sub


Sub createDisciplineList
	curs = Starter.clsDbe.lstDisciplines
	clsdbe.closeConnection
	clv_discipline.Clear
	curs.Position = 0

	For i = 0 To curs.RowCount - 1
		curs.Position = i
		clv_discipline.Add(genDisciplineList(curs.GetString("discipline"), curs.GetString("id"), clv_discipline.AsView.Width), "")
	Next
	curs.Close
End Sub


Sub genDisciplineList(disci As String, id As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 185dip)
	
	p.LoadLayout("clv_discipline")
	lbl_discipline_header.Text = disci
	lbl_discipline_header.Tag = "disci"
	p.Tag = id
	Return p
End Sub


Sub btn_new_Click
	Dim label As Label
	label.Initialize("")
	addEdit(False, label, "")
End Sub


Sub lbl_discipline_header_Click
	clsFunc.colorHeader(clv_discipline, Sender)
	
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
	clsFunc.colorHeader(clv_discipline, Sender)
End Sub


Sub lbl_delete_Click
	Dim index As Int = clsFunc.colorHeader(clv_discipline, Sender)
	
	Msgbox2Async($"Geselecteerde discipline verwijderen?"$, Application.LabelName, "Ja", "", "Nee", Null, False)
	
	Wait For Msgbox_Result (response As Int)
	
	If response = DialogResponse.POSITIVE Then
		removeItem(index)
	End If
End Sub


Sub removeItem(index As Int)
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
		txt_discipline_edit.Hint = "Nieuwe discipline"
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
End Sub



Sub lbl_add_Click
	Dim label As Label
	label.Initialize("")
	addEdit(False, label, "")
End Sub