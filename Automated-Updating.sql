USE [VC_WorkBench]
GO

/****** Object:  StoredProcedure [dbo].[VC_SP_UpdatingAuthRecords]    Script Date: 12/1/2023 11:30:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[VC_SP_UpdatingAuthRecords]
AS

--This update will update the authentication table for endless aisle that have been shipped.
UPDATE EA_VC.EndlessAisle.dbo.authentication
SET 
BPCode = A.CardCode,
ContactName = A.Name,
ContactEmail = A.E_MailL,
Location = A.CardName,
Location2 = A.U_cShipToCode,
MonitorSN = A.PACKSLIP
FROM		    VC_WorkBench.dbo.VC_EndlessAisleOrders A
INNER JOIN	EA_VC.EndlessAisle.dbo.vc_components B
ON			    A.CAPTUREDBC = B.totlabel
INNER JOIN	EA_VC.EndlessAisle.dbo.authentication C
ON			    B.compSerial = C.ComputerSN

--This update will update the MonitorSN column in the authentication table
UPDATE	    EA_VC.EndlessAisle.dbo.authentication
SET			    MonitorSN = A.compSerial
FROM		    EA_VC.EndlessAisle.dbo.vc_components A
INNER JOIN	VC_WorkBench.dbo.VC_EndlessAisleOrders B
ON			    A.totlabel = B.CAPTUREDBC
INNER JOIN	EA_VC.EndlessAisle.dbo.authentication C
ON			    B.PACKSLIP = C.MonitorSN
WHERE		    A.compType like 'Disp%'

--This update will set the MonitorSN number to NULL if no MonitorSN number was found in the vc_components table
UPDATE	EA_VC.EndlessAisle.dbo.authentication
SET		  MonitorSN = NULL
WHERE	  MonitorSN in (SELECT PACKSLIP FROM VC_WorkBench.dbo.VC_EndlessAisleOrders)
GO
