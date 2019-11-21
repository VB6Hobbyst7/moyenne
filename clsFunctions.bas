B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Dim clvHeaderPrimaryColor As String =  0xFF05B80A
	Dim clvHeaderHighlightColor As String =  0xFF0059FF
	'dim activity as Activity
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


Sub getPanelIndex(clv As CustomListView, sndr As Object) As Int
	Return clv.GetItemFromView(sndr)
End Sub


'RETURNS INDEX OF SELECTED PANEL
Sub colorHeader(clv As CustomListView, sndr As Object) As Int
	Dim index As Int
	Dim maxIndex As Int = clv.GetSize
	
	If sndr = Null Then
		index = Starter.partijenIndex
	Else
		index = getPanelIndex(clv, sndr)
	End If
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



Sub colorHeaderNew(clv As CustomListView, index As Int, oldIndex As String) As Int
	Dim pnl As Panel
	
	If oldIndex > -1 Then
		pnl = clv.GetPanel(oldIndex)
		For Each v As View In pnl.GetAllViewsRecursive
			If v Is Label Then
				If v.Tag = "disci" Then
					v.Color = clvHeaderPrimaryColor
				End If
			End If
		Next
	End If
	
	pnl = clv.GetPanel(index)
	For Each v As View In pnl.GetAllViewsRecursive
		If v Is Label Then
			If v.Tag = "disci" Then
				v.Color = clvHeaderHighlightColor
			End If
		End If
	Next
	
	Return index
	
End Sub

Sub backupData
	Dim FileName As String = "moyenne.db"
	Dim backUpName As String = $"moyenne.${DateTime.Date(DateTime.Now)}.backup"$
	
	If File.Exists(Starter.share, FileName) Then
		Log("PPPPPPP")
	End If
	
	
	File.Copy(Starter.share, FileName, Starter.Provider.SharedFolder, backUpName)
	
	If File.Exists(Starter.Provider.SharedFolder, backUpName) Then
		Log("PPPPPPP")
	End If
	
	Dim in As Intent
	in.Initialize(in.ACTION_SEND, "")
	in.SetType("text/plain")
	in.PutExtra("android.intent.extra.STREAM", Starter.Provider.GetFileUri(backUpName))
	in.Flags = 1 'FLAG_GRANT_READ_URI_PERMISSION
	StartActivity(in)
End Sub

Sub restoreData
	Dim cc As ContentChooser
	cc.Initialize("cc")
	cc.Show("text/*", "Selecteer backup")
End Sub


Sub CC_Result (Success As Boolean, Dir As String, FileName As String)
	
	If Success = True Then
		Msgbox2Async($"Geselecteerde backup terug zetten?"$, Application.LabelName, "Ja", "", "Nee", Null, False)
	
		Wait For Msgbox_Result (response As Int)
	
		If response = DialogResponse.POSITIVE Then
			File.Copy(Dir, FileName, Starter.share, "moyenne.db")
		End If
	Else
		MsgboxAsync("Kan backup bestand laden", "Mijn Moyenne")
	End If
		
End Sub


Sub FontAwesomeToBitmap (Text As String, FontSize As Float) As B4XBitmap
	Dim xui As XUI
	Dim p As Panel = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 32dip, 32dip)
	Dim cvs1 As B4XCanvas
	cvs1.Initialize(p)
	Dim fnt As B4XFont = xui.CreateFont(Typeface.FONTAWESOME, FontSize)
	Dim r As B4XRect = cvs1.MeasureText(Text, fnt)
	Dim BaseLine As Int = cvs1.TargetRect.CenterY - r.Height / 2 - r.Top
	cvs1.DrawText(Text, cvs1.TargetRect.CenterX, BaseLine, fnt, xui.Color_White, "CENTER")
	Dim b As B4XBitmap = cvs1.CreateBitmap
	cvs1.Release
	Return b
End Sub

Sub BitmapToBitmapDrawable (bitmap As Bitmap) As BitmapDrawable
	Dim bd As BitmapDrawable
	bd.Initialize(bitmap)
	Return bd
End Sub



