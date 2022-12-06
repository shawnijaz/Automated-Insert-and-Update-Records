USE EndlessAisle

CREATE PROCEDURE VC_SP_EA_InsertCheck @LicKey VARCHAR(50), @HostName VARCHAR(45), @ComputerSN VARCHAR(10), @compSerial NVARCHAR(25), @totlabel NVARCHAR(30)
AS 

IF exists 
(
	SELECT * 
	FROM EndlessAisle.dbo.authentication A
	inner join vc_components B
	on A.ComputerSN = B.compSerial
	WHERE A.LicKey = @LicKey
	or A.HostName = @HostName 
	or A.ComputerSN = @ComputerSN
	or B.compSerial = @compSerial
	or B.totlabel = @totlabel
)
BEGIN
	IF exists
	(
		SELECT LicKey 
		FROM EndlessAisle.dbo.authentication 
		WHERE LicKey = @LicKey
	)
	PRINT('This LicKey already exists')
	
	IF exists
	(
		SELECT HostName 
		FROM EndlessAisle.dbo.authentication 
		WHERE HostName = @HostName  
	)
	PRINT('This HostName already exists')
	
	IF exists
	(
		SELECT ComputerSN 
		FROM EndlessAisle.dbo.authentication 
		WHERE ComputerSN = @ComputerSN
	)
	PRINT('This ComputerSN already exists')

	IF exists 
	(
		SELECT compSerial 
		FROM EndlessAisle.dbo.vc_components 
		WHERE compSerial = @compSerial 
	)
	PRINT('This compSerial already exists')

	IF exists 
	(
		SELECT totlabel
		FROM EndlessAisle.dbo.vc_components 
		WHERE totlabel = @totlabel
	)
	PRINT('This totlabel already exists')
END
ELSE
BEGIN
	INSERT INTO EndlessAisle.dbo.authentication (LicKey, BPCode, ShowNew, ContactName, ContactEmail, HostName, StartDate, EndDate, Active, pricelist, ComputerSN, hidepricing, Region)
	VALUES (@LicKey, 0, 1, 'name', 'email', @HostName, GETDATE(), '2999-12-31', 'Y', 3, @ComputerSN, 0, 'US')

	INSERT INTO EndlessAisle.dbo.vc_custbrands (idAuth, BrandID, BrandOrder, pricelist)
	VALUES ((SELECT max(idAuth) FROM EndlessAisle.dbo.authentication), 1000, 1, 3)

	INSERT INTO EndlessAisle.dbo.vc_components
	VALUES ('ECM', @compSerial, @totlabel)
END
