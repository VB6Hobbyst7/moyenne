B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.5
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	Dim clsFunc As clsFunctions
	Dim clsDbe As clsDb
	Public Provider As FileProvider
	Dim rp As RuntimePermissions
	Public share, partijLastId As String = ""
	Public yearForChart As String
	Public disciplineForChart, disciplineName As String
	Public game_id As String
	Public partijenIndex As Int = -1
	Public partijenOffset As Int
	Public disciplineIndex As Int = -1
	Public partijSender As Object
	Public partijDisciplineChanged As Boolean = False
	Public partijNewDiscipline As String
	Public disciplineId As String
	
End Sub

Sub Service_Create
	share  = rp.GetSafeDirDefaultExternal("irp_files")
	rp.GetSafeDirDefaultExternal("shared")
	clsFunc.Initialize
	clsDbe.Initialize
	Provider.Initialize
	clsDbe.disciplineExists("")
	clsDbe.closeConnection
	createSeachLists
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub


Sub createSeachLists
	If File.Exists(share, "location.txt") = False Then
		File.WriteString(share, "location.txt", "")
	End If
	If File.Exists(share, "opponent.txt") = False Then
		File.WriteString(share, "opponent.txt", "")
	End If
	
	
	
End Sub
