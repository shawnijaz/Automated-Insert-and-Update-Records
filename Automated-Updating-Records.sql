USE VC_WorkBench

CREATE PROCEDURE VC_SP_EndlessAisleOrders
AS

IF EXISTS(
			SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME = 'VC_EndlessAisleOrders' AND TABLE_SCHEMA = 'dbo'
		)
	DROP TABLE VC_EndlessAisleOrders

SELECT SM.PACKSLIP
, SM.CAPTUREDBC
, TM.ItemCode
, TM.ItemName
, SM.DATE_SHIP
, RD.CardCode
, RD.CardName
, PR.[Name]
, PR.E_MailL
, DR.U_cShipToCode
INTO VC_WorkBench.dbo.VC_EndlessAisleOrders
FROM Accellosone.DBO.SHIPMSTR SM
INNER JOIN Accellosone.DBO.SHIPDETL2 SD
ON SM.TOTLABEL = SD.TOTLABEL
AND SM.PACKSLIP = SD.PACKSLIP
INNER JOIN VCTest3.DBO.OITM TM
ON SD.PRODUCT = TM.ItemCode COLLATE DATABASE_DEFAULT
INNER JOIN VCTest3.DBO.ORDR DR
ON LEFT(SM.PACKSLIP,ISNULL(NULLIF(CHARINDEX('-',SM.PACKSLIP),0),LEN(SM.PACKSLIP)+1)-1) = DR.DocNum
INNER JOIN VCTest3.DBO.OCRD RD
ON DR.CardCode = RD.CardCode
INNER JOIN VCTest3.DBO.OCPR PR
ON RD.CardCode = PR.CardCode
AND RD.CntctPrsn = PR.[Name]
WHERE 1=1
AND TM.ItemName NOT IN ('ELOCTRL','ELOMNT_65','ELOMNT_55')
AND TM.ItemName LIKE '%CPU%'
AND
(
LEFT(SM.PACKSLIP,7) IN (
								SELECT		CAST(NV.DocNum AS NVARCHAR(7))
								FROM		VCTest3.dbo.ORDR NV
								INNER JOIN	VCTest3.dbo.RDR1 V1
								ON			NV.DocEntry = V1.DocEntry
								INNER JOIN	VCTest3.dbo.OITM TM
								ON			V1.ItemCode = TM.ItemCode
								WHERE		1=1
								AND			TM.U_Sku_BC = 'ELO' AND TM.U_SELLINGLINESTATUS IN ('A','D','TBD','O', 'NA')
								AND			NV.CANCELED = 'N'
								AND			NV.TaxDate >= GETDATE() - 7
						)
OR SM.DATE_SHIP >=  GETDATE() - 7
)
ORDER BY SM.PACKSLIP

CREATE PROCEDURE VC_SP_UpdatingAuthRecords
AS

UPDATE EA_VC.EndlessAisle.dbo.authentication
SET 
BPCode = A.CardCode,
ContactName = A.Name,
ContactEmail = A.E_MailL,
Location = A.CardName,
Location2 = A.U_cShipToCode
FROM VC_WorkBench.dbo.VC_EndlessAisleOrders A
INNER JOIN EA_VC.EndlessAisle.dbo.vc_components B
ON A.CAPTUREDBC = B.totlabel
INNER JOIN EA_VC.EndlessAisle.dbo.authentication C
ON B.compSerial = C.ComputerSN
