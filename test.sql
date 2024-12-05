CREATE OR REPLACE PROCEDURE VMMED.AP_MED_AUD_AJUSTE_CALIDAD (
   P_AREA          IN NUMBER DEFAULT NULL,
   P_REGISTRO      IN VARCHAR2 DEFAULT NULL,
   P_CALIDAD       IN VARCHAR2 DEFAULT NULL,
   P_OPCION        IN VARCHAR2 DEFAULT NULL,
   P_FECHA_DESDE   IN DATE DEFAULT NULL,
   P_FECHA_HASTA   IN DATE DEFAULT NULL)
AS
   v_area            NUMBER (5, 0) := P_AREA;
   v_registro        VARCHAR2 (1) := P_REGISTRO;
   v_calidad         VARCHAR2 (1) := P_CALIDAD;
   v_opcion          VARCHAR2 (8) := P_OPCION;
   v_fecha_desde     DATE := P_FECHA_DESDE;
   v_fecha_hasta     DATE := P_FECHA_HASTA;
   v_count2          INTEGER;
   v_stoo_error      INTEGER := 0;
   v_stoo_rowcnt     INTEGER;
   v_stoo_errmsg     VARCHAR2 (500);
   v_fecha_calidad   DATE;
   v_count1          NUMBER (5);
      
   v_molares_100           NUMBER; ----------------------
   v_dif_molares_100       NUMBER; ----------------------
    v_pr_n2       		   NUMBER;
    v_pr_co2       		   NUMBER;
    v_pr_c1       		   NUMBER;   
    v_pr_c2       		   NUMBER;   
    v_pr_c3       		   NUMBER;
    v_pr_c4       		   NUMBER;     
    v_pr_c4i       		   NUMBER;     
    v_pr_c5       		   NUMBER;  
    v_pr_c5i       		   NUMBER; 
    v_pr_c6       		   NUMBER;
    v_pr_c7       		   NUMBER;
    v_pr_c8       		   NUMBER;
    v_pr_c9       		   NUMBER;
    v_pr_c10       		   NUMBER; 
    v_pr_c11       		   NUMBER;  
    v_pr_c12       		   NUMBER;
   
BEGIN
	-- CONTROL DE 100% Y ASIGNACION A VARIABLE DE MAYOR PESO ---------------------------------
    -- sumo variables molares, para controlar el 100% ----------------------------------------
         SELECT c.pr_co2,
                c.pr_n2,
                NVL (c.pr_c1, 0),
                NVL (c.pr_c2, 0),
                NVL (c.pr_c3, 0),
                NVL (c.pr_c4i, 0),
                NVL (c.pr_c4, 0),
                NVL (c.pr_c5i, 0),
                NVL (c.pr_c5, 0),
                NVL (c.pr_c6, 0),
                NVL (c.pr_c7, 0),
                NVL (c.pr_c8, 0),
                NVL (c.pr_c9, 0),
                NVL (c.pr_c10, 0),
                NVL (c.pr_c11, 0),
                NVL (c.pr_c12, 0)
         INTO
            v_pr_co2 ,
            v_pr_n2  ,
            v_pr_c1  ,   
            v_pr_c2  ,   
            v_pr_c3  ,   
            v_pr_c4  ,   
            v_pr_c4i ,   
            v_pr_c5  ,   
            v_pr_c5i ,   
            v_pr_c6  ,   
            v_pr_c7  ,   
            v_pr_c8  ,   
            v_pr_c9  ,   
            v_pr_c10 ,   
            v_pr_c11 ,   
            v_pr_c12 
         FROM med_calidad_gas c, tt_aud_2 t
         WHERE     c.fe_calidad = t.fe_medicion
                   AND c.fr_calidad = t.fr_medicion
                   AND c.nr_calidad = v_area
                   AND t.fr_medicion = v_registro;

        v_molares_100 :=  v_pr_co2
                     + v_pr_n2 
                     + NVL (v_pr_c1, 0)
                     + NVL (v_pr_c2, 0)
                     + NVL (v_pr_c3, 0)
                     + NVL (v_pr_c4, 0)
                     + NVL (v_pr_c4i, 0)
                     + NVL (v_pr_c5, 0)
                     + NVL (v_pr_c5i, 0)
                     + NVL (v_pr_c6, 0)
                     + NVL (v_pr_c7, 0)
                     + NVL (v_pr_c8, 0)
                     + NVL (v_pr_c9, 0)
                     + NVL (v_pr_c10, 0)
                     + NVL (v_pr_c11, 0)
                     + NVL (v_pr_c12, 0);

    -- si v_molares_100 > 100 ====> v_dif_molares_100 va a quedar negativo
    -- si v_molares_100 < 100 ====> v_dif_molares_100 va a quedar positivo 
    IF v_molares_100 <> 100 THEN
       v_dif_molares_100 := 100 - v_molares_100;
    END IF;

    -- invoco funcion que busca la variable de mayor valor y le aplica la v_dif_molares_100 calculada (si es positiva, suma y si es negativa, resta)
    v_stoo_rowcnt := AP_MED_MAX_MOLAR (
    v_pr_co2  ,
    v_pr_n2  ,
    v_pr_c1  ,
    v_pr_c2  ,
    v_pr_c3  ,
    v_pr_c4  ,
    v_pr_c4i ,
    v_pr_c5  ,
    v_pr_c5i ,
    v_pr_c6  ,
    v_pr_c7  ,
    v_pr_c8  ,
    v_pr_c9  ,
    v_pr_c10 ,
    v_pr_c11 ,
    v_pr_c12 ,
    v_dif_molares_100);
	
   /* si ajusta por calidad habilitado con hora de calidad exacta */
   IF v_calidad = 'E'
   THEN
      BEGIN
         v_stoo_error := 0;
         v_stoo_rowcnt := 0;

         INSERT INTO tt_aud_3
            SELECT c.fe_calidad,
                   c.fr_calidad,
                   c.nr_calidad,
                   c.ca_poder_calor,
                   c.ca_densidad,
                   v_pr_co2, ------
                   v_pr_n2, ------
                   NVL (v_pr_c1, 0), ------
                   NVL (v_pr_c2, 0), ------
                   NVL (v_pr_c3, 0), ------
                   NVL (v_pr_c4i, 0), ------
                   NVL (v_pr_c4, 0), ------
                   NVL (v_pr_c5i, 0), ------
                   NVL (v_pr_c5, 0), ------
                   NVL (v_pr_c6, 0), ------
                   NVL (v_pr_c7, 0), ------
                   NVL (v_pr_c8, 0), ------
                   -- INICIO VACA MUERTA --
                   NVL (v_pr_c9, 0), ------
                   NVL (v_pr_c10, 0), ------
                   NVL (v_pr_c11, 0), ------
                   NVL (v_pr_c12, 0), ------
                   -- FIN VACA MUERTA --
                   c.fe_calidad
              FROM med_calidad_gas c, tt_aud_2 t
             WHERE     c.fe_calidad = t.fe_medicion
                   AND c.fr_calidad = t.fr_medicion
                   AND c.nr_calidad = v_area
                   AND t.fr_medicion = v_registro;

         v_stoo_rowcnt := SQL%ROWCOUNT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            v_stoo_error := SQLCODE;
            v_stoo_errmsg := SQLERRM;
            raise_application_error (SQLCODE, SQLERRM, TRUE);
      END;

      IF substring (v_opcion, 1, 1) = '1'
      THEN
         BEGIN
            v_stoo_error := 0;
            v_stoo_rowcnt := 0;
            v_count1 := 0;

            SELECT COUNT (*) INTO v_count1 FROM tt_aud_3;

            v_stoo_rowcnt := SQL%ROWCOUNT;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_stoo_error := SQLCODE;
               v_stoo_errmsg := SQLERRM;
               raise_application_error (SQLCODE, SQLERRM, TRUE);
         END;

         BEGIN
            v_count2 := 0;
            v_stoo_error := 0;
            v_stoo_rowcnt := 0;

            SELECT COUNT (*)
              INTO v_count2
              FROM tt_aud_2
             WHERE fr_medicion = v_registro;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_stoo_error := SQLCODE;
               v_stoo_errmsg := SQLERRM;
               raise_application_error (SQLCODE, SQLERRM, TRUE);
         END;

         IF v_count1 != v_count2
         THEN
            raise_application_error (
               -20999,
               'No existe la misma cantidad de registros para el area del punto que para el area.');
         END IF;
      END IF;

      IF substring (v_opcion, 1, 1) = '0'
      THEN
         BEGIN
            v_count2 := 0;
            v_stoo_error := 0;
            v_stoo_rowcnt := 0;

            SELECT COUNT (*)
              INTO v_count2
              FROM tt_aud_2
             WHERE     fr_medicion = v_registro
                   AND fe_medicion NOT IN (SELECT fe_medicion FROM tt_aud_3);
         EXCEPTION
            WHEN OTHERS
            THEN
               v_stoo_error := SQLCODE;
               v_stoo_errmsg := SQLERRM;
               raise_application_error (SQLCODE, SQLERRM, TRUE);
         END;

         IF v_count2 > 0
         THEN
            raise_application_error (
               -20999,
               'No existe la misma cantidad de registros para el area del punto que para el area.');
         END IF;
      END IF;
   END IF;

   /* si ajusta por calidad habilitado con hora de calidad del ultimo analisis */

   IF v_calidad = 'U'
   THEN
      BEGIN
         v_stoo_error := 0;
         v_stoo_rowcnt := 0;

         INSERT INTO tt_aud_3
            SELECT c.fe_calidad,
                   v_registro,
                   c.nr_calidad,
                   c.ca_poder_calor,
                   c.ca_densidad,
                   c.pr_co2,
                   c.pr_n2,
                   (  100
                    - c.pr_n2
                    - c.pr_co2
                    - NVL (c.pr_c2, 0)
                    - NVL (c.pr_c3, 0)
                    - NVL (c.pr_c4, 0)
                    - NVL (c.pr_c4i, 0)
                    - NVL (c.pr_c5, 0)
                    - NVL (c.pr_c5i, 0)
                    - NVL (c.pr_c6, 0)
                    - NVL (c.pr_c7, 0)
                    - NVL (c.pr_c8, 0)
                    -- INICIO VACA MUERTA --
                    - NVL (c.pr_c9, 0)
                    - NVL (c.pr_c10, 0)
                    - NVL (c.pr_c11, 0)
                    - NVL (c.pr_c12, 0)),
                   -- FIN VACA MUERTA --

                   NVL (c.pr_c2, 0),
                   NVL (c.pr_c3, 0),
                   NVL (c.pr_c4i, 0),
                   NVL (c.pr_c4, 0),
                   NVL (c.pr_c5i, 0),
                   NVL (c.pr_c5, 0),
                   NVL (c.pr_c6, 0),
                   NVL (c.pr_c7, 0),
                   NVL (c.pr_c8, 0),
                   -- INICIO VACA MUERTA --
                   NVL (c.pr_c9, 0),
                   NVL (c.pr_c10, 0),
                   NVL (c.pr_c11, 0),
                   NVL (c.pr_c12, 0),
                   -- FIN VACA MUERTA --

                   c.fe_calidad
              FROM med_calidad_gas c
             WHERE     c.fr_calidad = 'D'
                   AND c.nr_calidad = v_area
                   AND c.fe_calidad IN
                          (SELECT MAX (g.fe_calidad)
                             FROM med_calidad_gas g
                            WHERE     g.fe_calidad <= v_fecha_hasta
                                  AND g.fr_calidad = 'D'
                                  AND g.nr_calidad = v_area);

         v_stoo_rowcnt := SQL%ROWCOUNT;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            v_stoo_error := SQLCODE;
            v_stoo_errmsg := SQLERRM;
            raise_application_error (SQLCODE, SQLERRM, TRUE);
      END;

      IF v_stoo_rowcnt = 0
      THEN
         raise_application_error (
            -20999,
            'No existe el registro de ultimo an�lisis.');
      END IF;
   END IF;
END AP_MED_AUD_AJUSTE_CALIDAD;
/

CREATE OR REPLACE PUBLIC SYNONYM AP_MED_AUD_AJUSTE_CALIDAD FOR VMMED.AP_MED_AUD_AJUSTE_CALIDAD;


GRANT EXECUTE ON VMMED.AP_MED_AUD_AJUSTE_CALIDAD TO GR_VMMED_SE;

GRANT EXECUTE ON VMMED.AP_MED_AUD_AJUSTE_CALIDAD TO GR_VMMED_SUIDE;
