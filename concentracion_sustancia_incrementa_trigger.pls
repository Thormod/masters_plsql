CREATE OR REPLACE EDITIONABLE TRIGGER "CONCENTRACION_SUSTANCIA_IN" 
AFTER
	update of "VALVULA" OR update of "MARCA_DE_TIEMPO" on "VARIABLE"
DECLARE
    v_coeficiente_variacion PARAMETRO.COEFICIENTE_DE_VARIACION%TYPE;
    v_cant_inicial_sus_liq PARAMETRO.CANTIDAD_INICIAL_SUSTANCIA_LIQ%TYPE;
    v_concentracion PARAMETRO.CONCENTRACION%TYPE;

    v_valvula VARIABLE.VALVULA%TYPE;
    v_tiempo_mezcla VARIABLE.TIEMPO_MEZCLA%TYPE;
    v_marca_de_tiempo VARIABLE.MARCA_DE_TIEMPO%TYPE;

    v_codigo_mezcla MEZCLA.CODIGO%TYPE;
    v_velocidad_minima_mezcla MEZCLA.VELOCIDAD_MINIMA%TYPE;

    v_codigo_concentracion CONCENTRACION_DE_SUSTANCIA.CODIGO%TYPE;
    v_cantidad_sustancia_liqu CONCENTRACION_DE_SUSTANCIA.CANTIDAD_DE_SUSTANCIA_LIQUIDA%TYPE;
    v_cant_sustancia_soluble CONCENTRACION_DE_SUSTANCIA.CANTIDAD_DE_SUSTANCIA_SOLUBLE%TYPE;
    v_codigo_mezcla_concentracion CONCENTRACION_DE_SUSTANCIA.CODIGO_MEZCLA%TYPE;
    v_cantidad_minima_sustanc CONCENTRACION_DE_SUSTANCIA.CANTIDAD_MINIMA_DE_SUSTANCIA_L%TYPE;
    v_tiempo_local_concentracion CONCENTRACION_DE_SUSTANCIA.TIEMPO_LOCAL%TYPE;
BEGIN
    SELECT COEFICIENTE_DE_VARIACION INTO v_coeficiente_variacion FROM PARAMETRO;
    SELECT CANTIDAD_INICIAL_SUSTANCIA_LIQ INTO v_cant_inicial_sus_liq FROM PARAMETRO;
    SELECT CONCENTRACION INTO v_concentracion FROM PARAMETRO;

	SELECT MARCA_DE_TIEMPO INTO v_marca_de_tiempo FROM VARIABLE;
    SELECT TIEMPO_MEZCLA INTO v_tiempo_mezcla FROM VARIABLE;
    SELECT VALVULA INTO v_valvula FROM VARIABLE;

    SELECT CODIGO INTO v_codigo_mezcla FROM MEZCLA ORDER BY CODIGO DESC FETCH FIRST 1 ROWS ONLY;
    SELECT VELOCIDAD_MINIMA INTO v_velocidad_minima_mezcla FROM MEZCLA WHERE CODIGO = v_codigo_mezcla;

    SELECT CODIGO INTO v_codigo_concentracion FROM CONCENTRACION_DE_SUSTANCIA ORDER BY CODIGO DESC FETCH FIRST 1 ROWS ONLY;
    SELECT CANTIDAD_DE_SUSTANCIA_LIQUIDA INTO v_cantidad_sustancia_liqu FROM CONCENTRACION_DE_SUSTANCIA WHERE CODIGO = v_codigo_concentracion;
    SELECT CANTIDAD_DE_SUSTANCIA_SOLUBLE INTO v_cant_sustancia_soluble FROM CONCENTRACION_DE_SUSTANCIA WHERE CODIGO = v_codigo_concentracion;
    SELECT CODIGO_MEZCLA INTO v_codigo_mezcla_concentracion FROM CONCENTRACION_DE_SUSTANCIA WHERE CODIGO = v_codigo_concentracion;
    SELECT CANTIDAD_MINIMA_DE_SUSTANCIA_L INTO v_cantidad_minima_sustanc FROM CONCENTRACION_DE_SUSTANCIA WHERE CODIGO = v_codigo_concentracion;
    SELECT TIEMPO_LOCAL INTO v_tiempo_local_concentracion FROM CONCENTRACION_DE_SUSTANCIA WHERE CODIGO = v_codigo_concentracion;

    IF v_marca_de_tiempo = 'PARE' AND v_valvula = 'ABIERTA' THEN
        v_codigo_concentracion := v_codigo_concentracion + 1;
        v_tiempo_local_concentracion := v_tiempo_mezcla;
        v_cantidad_sustancia_liqu := v_cant_inicial_sus_liq + v_cantidad_minima_sustanc;
        v_cantidad_minima_sustanc := v_velocidad_minima_mezcla * v_tiempo_mezcla;
        v_cant_sustancia_soluble := ((v_cant_inicial_sus_liq + v_cantidad_minima_sustanc) * v_concentracion)  + (power(v_cant_inicial_sus_liq + v_cantidad_minima_sustanc,2)/v_coeficiente_variacion);

        INSERT INTO CONCENTRACION_DE_SUSTANCIA (CODIGO, CANTIDAD_DE_SUSTANCIA_LIQUIDA, CANTIDAD_MINIMA_DE_SUSTANCIA_L, CANTIDAD_DE_SUSTANCIA_SOLUBLE, CODIGO_MEZCLA, TIEMPO_LOCAL) 
        VALUES (v_codigo_concentracion, v_cantidad_sustancia_liqu, v_cantidad_minima_sustanc, v_cant_sustancia_soluble, v_codigo_mezcla, v_tiempo_local_concentracion);
    END IF;
END;
