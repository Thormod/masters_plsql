CREATE OR REPLACE EDITIONABLE TRIGGER "TIEMPO_PASA_1" 
AFTER
	update of "TIEMPO_MEZCLA" on "VARIABLE"
BEGIN
	UPDATE VARIABLE SET MARCA_DE_TIEMPO='PARE';
END;