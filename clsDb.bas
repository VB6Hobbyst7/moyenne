B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private db As String = $"moyenne.db"$
	Private sql As SQL
	Public curs As Cursor
	Private qry As String
	Dim clsFunc As clsFunctions
	
	
End Sub


Public Sub Initialize
	If File.Exists(Starter.share, "moyenne.db") = False Then
		File.Copy(File.DirAssets, "moyenne.db", Starter.share, "moyenne.db")
	End If
	clsFunc.Initialize
End Sub


Sub initDb
	If sql.IsInitialized = False Then
		sql.Initialize(Starter.share, db, False)
	End If
End Sub

Sub closeConnection
	If sql.IsInitialized Then
		sql.Close
	End If
	If curs.IsInitialized Then
		curs.Close
	End If
End Sub

Sub lastInsertedId(tabel As String) As String
	initDb
	qry = $"SELECT id FROM ${tabel} ORDER BY date_time DESC LIMIT 1;"$
	curs = sql.ExecQuery(qry)
	
	curs.Position = 0
	Return curs.GetString("id")
End Sub

#Region discipline
Sub addDiscipline(disc As String, disciId As String)
	initDb
	If disciplineExists(disc) = True Then
		ToastMessageShow($"${disc} bestaat reeds"$, True)
		Return
	End If
	If disciId.Length > 8 Then
		qry = "update disciplines set discipline = ? where id = ?"
		sql.ExecNonQuery2(qry, Array As String(disc, disciId))
	Else
		disciId = Starter.clsFunc.UUIDv4
		qry = "insert into disciplines (id, discipline) values (?,?,?)"
		sql.ExecNonQuery2(qry, Array As String(disciId, disc, 0))
	End If
	
	
End Sub

Sub deleteDiscipline(id As String)
	initDb
	qry = "delete from disciplines where id=?"
	sql.ExecNonQuery2(qry, Array As String(id))
End Sub

Sub disciplineExists(disc As String) As Boolean
	initDb
	qry = "select count(*) as result from disciplines where discipline = ?"
	curs = sql.ExecQuery2(qry, Array As String(disc))
	
	curs.Position = 0
	If curs.GetInt("result") > 0 Then
		Return True
	End If
	Return False
End Sub

Sub lstDisciplines As Cursor
	initDb
	qry = "select discipline, id, is_default from disciplines order by discipline"
	curs = sql.ExecQuery(qry)
	Return curs
End Sub

Sub retDisciplines As Cursor
	initDb
	
	qry = "select * from disciplines order by is_default DESC"
	curs = sql.ExecQuery(qry)
	Return curs
End Sub

Sub uncheckDiscipline(id As String, check As String)
	initDb
	qry = "update disciplines set is_default = ? where id = ?"
	sql.ExecNonQuery2(qry, Array As String(check, id))
	
End Sub

#End Region 


#Region partijen

Sub addPartij(location As String, beurten As String, caroms As String, moyenne As String, tegen As String, caroms_tegen As String, moyenne_tegen As String, date As Long, groot As Int)
	Dim month, year, winst As Int
	
	month = DateTime.GetMonth(date)
	year = DateTime.GetYear(date)
	winst = groot
	
	initDb
	qry = "insert into partijen (id, location, beurten, caroms, moyenne, opponent, caroms_opponent, moyenne_opponent, date_time, discipline_id, month, year, tafel_groot) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
	sql.ExecNonQuery2(qry, Array As String(clsFunc.UUIDv4, location, beurten, caroms, moyenne, tegen, caroms_tegen, moyenne_tegen, date, CallSub(nieuwe_partij, "retDiscipId"), month, year, winst))
End Sub

Sub updatePartij(location As String, beurten As String, caroms As String, moyenne As String, tegen As String, caroms_tegen As String, moyenne_tegen As String, date As Long, groot As Int)
	Dim month, year As Int
	
	month = DateTime.GetMonth(date)
	year = DateTime.GetYear(date)
	initDb
	qry = "update partijen set location=?, beurten=?, caroms=?, moyenne=?, opponent=?, caroms_opponent=?, moyenne_opponent=?, date_time=?, discipline_id=?, month=?, year=?, tafel_groot=? where id =?"
	sql.ExecNonQuery2(qry, Array As String(location, beurten, caroms, moyenne, tegen, caroms_tegen, moyenne_tegen, date, CallSub(nieuwe_partij, "retDiscipId"), month, year, groot, Starter.game_id))
End Sub


Sub deletePartij(id As String)
	initDb
	qry = "delete from partijen where id=?"
	sql.ExecNonQuery2(qry, Array As String(id))
	
End Sub

Sub retPartijen(id As String, year As String) As Cursor
	initDb
	
	qry = "select * from partijen where discipline_id=? and year=? order by date_time"
	curs = sql.ExecQuery2(qry, Array As String(id, year))
	Return curs
End Sub

Sub UniqueYears As Cursor
	initDb
	qry = "select distinct year from partijen where year IS NOT NULL order by year DESC"
	curs = sql.ExecQuery(qry)
	Return curs
	
End Sub


Sub genMoyenneMonthCurrYear(year As Int) As Cursor
	initDb
	qry = "select month, avg(moyenne) As avg_gem, year from partijen where discipline_id=? and year=? group by month, year order by month"
	curs = sql.ExecQuery2(qry, Array As String(Starter.disciplineForChart, year))
	Return curs
End Sub

Sub genMoyenneMonthPrevYear(year As Int) As Cursor
	initDb
	qry = "select month, avg(moyenne) As avg_gem, year from partijen where discipline_id=? and year=? group by month, year order by month"
	curs = sql.ExecQuery2(qry, Array As String(Starter.disciplineForChart, year))
	Return curs
End Sub

Sub genDisciplineAvg (id As String, year As String) As Cursor
	initDb
	qry = "select avg(moyenne) As avg_gem from partijen where discipline_id=? and year=?"
	curs = sql.ExecQuery2(qry, Array As String(id, year))
	Return curs
End Sub

Sub retrieveGameData(id As String)
	initDb
	
	qry = "select * from partijen where id=?"
	curs = sql.ExecQuery2(qry, Array As String(id))
End Sub

Sub RetrieveDisciplinePartijen(id As String)
	initDb
	qry = "select count(*) as count from partijen where discipline_id = ?"
	curs = sql.ExecQuery2(qry, Array As String(id))
End Sub

Sub partijSummary(disciplineId As String)
	initDb
	qry = $"SELECT
	sum(caroms) tot_car, AVG(caroms) avg_car, AVG(moyenne) moy, count(*) tot_games,max(date_time) date_time,
	(
		SELECT max(caroms) partijen
	) as hoogste_serie , sum(tafel_groot) as winst, (count(*)-sum(tafel_groot)) as verlies
	FROM partijen
	WHERE discipline_id = ?
	GROUP by discipline_id"$
	
	curs = sql.ExecQuery2(qry, Array As String(disciplineId))
	
End Sub

#End Region

