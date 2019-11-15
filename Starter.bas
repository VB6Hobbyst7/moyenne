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
	Dim rp As RuntimePermissions
	Public share As String
End Sub

Sub Service_Create
	share  = rp.GetSafeDirDefaultExternal("irp_files")
	clsFunc.Initialize
	clsDbe.Initialize
	clsDbe.disciplineExists("")
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


