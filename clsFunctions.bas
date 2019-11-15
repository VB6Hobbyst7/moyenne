B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Dim clvHeaderPrimaryColor As String =  0xFF05B80A
	Dim clvHeaderHighlightColor As String =  0xFF0059FF
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub


Sub UUIDv4 As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			If sb.Length = 19 Then c = Asc("8")
			If sb.Length = 14 Then c = Asc("4")
			sb.Append(Chr(c))
		Next
	Next
	Return sb.ToString.ToLowerCase
End Sub


Sub SetBackgroundTintList(View As View,Active As Int, Enabled As Int)
	Dim States(2,1) As Int
	States(0,0) = 16842908     'Active
	States(1,0) = 16842910    'Enabled
	Dim Color(2) As Int = Array As Int(Active,Enabled)
	Dim CSL As JavaObject
	CSL.InitializeNewInstance("android.content.res.ColorStateList",Array As Object(States,Color))
	Dim jo As JavaObject
	jo.InitializeStatic("android.support.v4.view.ViewCompat")
	jo.RunMethod("setBackgroundTintList", Array(View, CSL))
End Sub

Sub getPanelIndex(clv As CustomListView, sndr As Object) As Int
	Return clv.GetItemFromView(sndr)
End Sub


'RETURNS INDEX OF SELECTED PANEL
Sub colorHeader(clv As CustomListView, sndr As Object) As Int
	
	Dim maxIndex As Int = clv.GetSize
	Dim index As Int = getPanelIndex(clv, sndr)
	Dim pnl As Panel	
	
	For i = 0 To maxIndex - 1
		pnl = clv.GetPanel(i)
		
		For Each v As View In pnl.GetAllViewsRecursive
			If v Is Label Then
				If v.Tag = "disci" Then
					v.Color = clvHeaderPrimaryColor
					If i = index Then
						v.Color = clvHeaderHighlightColor
					End If
				End If
			End If
		Next
	Next
	
	Return index
	
End Sub




