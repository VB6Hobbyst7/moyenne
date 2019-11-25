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
	Dim cc As ContentChooser
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	cc.Initialize("cc")
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
	Dim backUpName As String
		
	DateTime.DateFormat = "dd_MM_yyyy_HH_mm"

	backUpName = $"myMoyenne_$Date{DateTime.Now}.txt"$
	
	File.Copy(Starter.share, FileName, Starter.Provider.SharedFolder, backUpName)
	
	Dim in As Intent
	in.Initialize(in.ACTION_SEND, "")
	in.SetType("text/plain")
	in.PutExtra("android.intent.extra.STREAM", Starter.Provider.GetFileUri(backUpName))
	in.Flags = 1 'FLAG_GRANT_READ_URI_PERMISSION
	StartActivity(in)
	
	DateTime.DateFormat = "dd-MM-yyyy"
End Sub

Sub restoreData
'	Dim cc As ContentChooser
'	cc.Initialize("cc")
	cc.Show("text/*", "Selecteer backup")
End Sub


Sub CC_Result (Success As Boolean, Dir As String, FileName As String)
	
	If Success = True Then
		Msgbox2Async($"Geselecteerde backup terug zetten?"$, Application.LabelName, "Ja", "", "Nee", Null, False)
	
		Wait For Msgbox_Result (response As Int)
	
		If response = DialogResponse.POSITIVE Then
			File.Copy(Dir, FileName, Starter.share, "moyenne.db")
			Wait For (File.CopyAsync(Dir, FileName, Starter.share, "moyenne.db")) Complete (Success As Boolean)
			
			If Success Then
				createCustomToast("Data uit de backup terug gezet..")
				Wait For(CallSub(partijen, "initiateData")) Complete(result As Boolean)
			Else 
				MsgboxAsync("Backup terug niet gezet", Application.LabelName)
			End If
		End If
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


'padText e.g. "9", padChar e.g. "0", padSide 0=left 1=right, padCount e.g. 2
Public Sub padString(padText As String ,padChr As String, padSide As Int, padCount As Int) As String
	Dim padStr As String
	
	If padText.Length = padCount Then
		Return padText
	End If
	
	For i = 1 To padCount
		padStr = padStr&padChr
	Next
	
	If padStr = 0 Then
		Return padStr&padText
	Else
		Return padText&padStr
	End If
	
End Sub


Sub createCustomToast(txt As String)
	Dim cs As CSBuilder
	cs.Initialize.Typeface(Typeface.LoadFromAssets("Montserrat-Regular.ttf")).Color(Colors.White).Size(16).Append(txt).PopAll
	ShowCustomToast(cs, True, clvHeaderHighlightColor)
End Sub

Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	'uncomment to show toast in the center:
	 '  toast.RunMethod("setGravity", Array( _
	  ' Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
End Sub