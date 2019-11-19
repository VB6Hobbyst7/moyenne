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
	Dim xui As XUI
	Private clsDbe As clsDb
	Type ChartData (month(12) As String, yearPrev(12) As String, _
		gemPrev(12) As Double, yearCurr(12) As String, gemCurr(12) As Double, gemCurrYear(12) As Double, gemPrevYear(12) As Double)
	Dim dataChart As ChartData
End Sub

Sub Globals
	Private chart As xChart
	Private gem As Double
	Private lbl_discipline As Label
	Private gameId As String
	Private toolbar As ACToolBarDark
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("partij_chart")
	toolbar.SubTitle = Starter.disciplineName
	clsDbe.Initialize
	gameId = Starter.disciplineId
	genChart
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub genChart
	Dim yearFrom, yearTo As String
	
	yearFrom = Starter.yearForChart-1
	yearTo = Starter.yearForChart
	
	processData
	
	chart.ClearData
	chart.Title = $"Overzicht ${yearFrom} - ${yearTo}"$
	chart.XAxisName = "Maand"
	chart.YAxisName = "Moyenne"
	
	chart.ClearData
	chart.AddLine2(yearTo, xui.Color_Blue, 2dip, "CIRCLE", False, xui.Color_Blue)
	chart.AddLine2(yearFrom, xui.Color_Red, 2dip, "CIRCLE", False, xui.Color_Red)
	chart.AddLine2($"Gem. ${yearTo}"$, xui.Color_Blue, 1dip, "NONE", False, xui.Color_Magenta)
	chart.AddLine2($"Gem. ${yearFrom}"$, xui.Color_Red, 1dip, "NONE", False, xui.Color_Magenta)
	
	
	For i = 0 To 11
		chart.AddLineMultiplePoints(dataChart.month(i), Array As Double(chart.NumberFormat3(dataChart.gemCurr(i), 3), chart.NumberFormat3(dataChart.gemPrev(i), 3), chart.NumberFormat3(dataChart.gemCurrYear(i), 3), chart.NumberFormat3(dataChart.gemPrevYear(i), 3)), True)
	Next

	
	chart.IncludeLegend="BOTTOM"
	chart.SetBarMeanValueFormat(1, 3, 3, False)
	chart.DrawChart
	
End Sub


Sub processData
	Dim month As Int
	Dim gemYear As Double = 0.00

	Dim cursPrevYear As Cursor = clsDbe.genMoyenneMonthPrevYear(Starter.yearForChart-1)
	Dim dataChart As ChartData
	dataChart.Initialize
	For i = 0 To 11
		dataChart.month(i) = i+1
		dataChart.gemCurr(i) = 0.00
		dataChart.gemPrev(i) = 0.00
	Next
	
	
	If cursPrevYear.RowCount > 0 Then
		For i = 0 To cursPrevYear.RowCount -1
			cursPrevYear.Position = i
			gem = cursPrevYear.GetDouble("avg_gem")
			gemYear = gemYear + gem
			month = cursPrevYear.GetInt("month")-1
			dataChart.yearPrev(month) = cursPrevYear.GetString("year")
			dataChart.gemPrev(month) = gem
		Next
	End If
	cursPrevYear.Close
	clsDbe.closeConnection
	'SET MOYENNE YEAR
	clsDbe.genDisciplineAvg(gameId, Starter.yearForChart-1)
	clsDbe.curs.Position = 0
	gemYear = clsDbe.curs.GetDouble("avg_gem")
	clsDbe.closeConnection
	For i = 0 To 11
		dataChart.gemPrevYear(i) = gemYear'/12
	Next
	
	
	gemYear = 0.00
	Dim cursCurrYear As Cursor = clsDbe.genMoyenneMonthCurrYear(Starter.yearForChart)
	If cursCurrYear.RowCount > 0 Then
		For i = 0 To cursCurrYear.RowCount -1
			cursCurrYear.Position = i
			gem = cursCurrYear.GetDouble("avg_gem")
			gemYear = gemYear + gem
			month = cursCurrYear.GetInt("month")-1
			dataChart.yearCurr(month) = cursCurrYear.GetString("year")
			dataChart.gemCurr(month) = gem
		Next
	End If
	clsDbe.closeConnection
	cursCurrYear.Close
	
	clsDbe.genDisciplineAvg(gameId, Starter.yearForChart)
	clsDbe.curs.Position = 0
	gemYear = clsDbe.curs.GetDouble("avg_gem")
	clsDbe.closeConnection
	'SET MOYENNE YEAR
	For i = 0 To 11
		dataChart.gemCurrYear(i) = gemYear'/12
	Next

	
	
End Sub
