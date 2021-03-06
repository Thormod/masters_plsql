CREATE OR REPLACE EDITIONABLE TRIGGER "MEZCLA_FINALIZA_SIMULACION" 
AFTER
	update of "TIEMPO" on "VARIABLE"
DECLARE
	v_tiempo VARIABLE.TIEMPO%TYPE;
	v_tiempo_de_simulacion PARAMETRO.TIEMPO_DE_SIMULACION%TYPE;
BEGIN
	SELECT TIEMPO INTO v_tiempo FROM VARIABLE;
	SELECT TIEMPO_DE_SIMULACION INTO v_tiempo_de_simulacion FROM PARAMETRO;

	IF v_tiempo > v_tiempo_de_simulacion THEN
		UPDATE VARIABLE SET VALVULA='CERRADA';
	END IF;
END;
