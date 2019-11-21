B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
Sub Process_Globals
End Sub



Sub FontBit (icon As String, font_size As Float, color As Int, awesome As Boolean) As Bitmap
	If color = 0 Then color = Colors.White
	Dim typ As Typeface = Typeface.MATERIALICONS
	If awesome Then typ = Typeface.FONTAWESOME
	Dim bmp As Bitmap
	bmp.InitializeMutable(32dip, 32dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim h As Double
	If Not(awesome) Then
		h = cvs.MeasureStringHeight(icon, typ, font_size) + 10dip
	Else
		h = cvs.MeasureStringHeight(icon, typ, font_size)
	End If
	cvs.DrawText(icon, bmp.Width / 2, bmp.Height / 2 + h / 2, typ, font_size, color, "CENTER")
	Return bmp
End Sub






