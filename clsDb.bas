B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private db As String = $"moyenne.db"$
	Private sql As SQL
	Private curs As Cursor
	Private qry As String
End Sub


Public Sub Initialize
	If File.Exists(Starter.share, db) = False Then
		File.Copy(File.DirAssets, db, Starter.share, db)
	End If
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
		qry = "insert into disciplines (id, discipline) values (?,?)"
		sql.ExecNonQuery2(qry, Array As String(disciId, disc))
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
	qry = "select discipline, id from disciplines order by discipline"
	curs = sql.ExecQuery(qry)
	Return curs
End Sub

Sub retDisciplines As Cursor
	initDb
	
	qry = "select * from disciplines order by discipline"
	curs = sql.ExecQuery(qry)
	Return curs
End Sub
#End Region 


#Region partijen

#End Region