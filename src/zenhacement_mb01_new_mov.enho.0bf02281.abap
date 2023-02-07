"Name: \PR:SAPMM07M\EX:FCODE_BEARBEITEN_02\EI
ENHANCEMENT 0 ZENHACEMENT_MB01_NEW_MOV.

          DATA: IT_MESSAGE TYPE ESP1_MESSAGE_TAB_TYPE,
                WA_CFDITR_MOV TYPE ZCFDITR_MOV,
                IT_EMAIL   TYPE STANDARD TABLE OF ZSTDSFIRE170_EMAIL,
                VL_RETURN  TYPE ABAP_BOOL,
                TIPO       TYPE CHAR3,
                UCOMM      TYPE CHAR4.

          READ TABLE XMSEG INDEX 1.
          SELECT SINGLE * INTO WA_CFDITR_MOV FROM ZCFDITR_MOV WHERE BWART EQ XMSEG-BWART.
          IF SY-SUBRC EQ 0.

            CALL FUNCTION 'ZMF_SCREEN_DATOS_ADICIONALES'
            IMPORTING
              TIPO          = TIPO
              UCOMM         = UCOMM
            TABLES
              XMSEG         = XMSEG.

            IF TIPO EQ 'GCC'.

              CALL FUNCTION 'ZCFDIMF020_GENERATE_CFDI_TR'
              EXPORTING
                XMKPF   = XMKPF
              IMPORTING
                RETURN  = VL_RETURN
              TABLES
                XMSEG      = XMSEG
                IT_MESSAGE = IT_MESSAGE
                IT_EMAIL   = IT_EMAIL.

              IF IT_EMAIL[] IS NOT INITIAL AND VL_RETURN EQ ABAP_FALSE.

                CALL FUNCTION 'ZCFDITRMF_CORREOS_33'
                TABLES
                  IT_DATA_IN    = IT_EMAIL.

                CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
                TABLES
                  I_MESSAGE_TAB = IT_MESSAGE.
              ELSE.
                MESSAGE S060 WITH XMKPF-MBLNR.
              ENDIF.
            ENDIF.
          ENDIF.


        MESSAGE s060 WITH xmkpf-mblnr.

*          IF ( SY-TCODE EQ 'MB01'
*          OR SY-TCODE EQ 'MB0A' )
*          AND XMKPF-MBLNR IS NOT INITIAL.
*            BREAK jpmorin.
*
*              READ TABLE XMSEG INDEX 1.
*
*              IF XMSEG-BWART EQ '101'.
*                EXPORT XMSEG[] TO MEMORY ID 'CU09_MSEG'.
*              ENDIF.
*
*              COMMIT WORK AND WAIT.
*
*              EXPORT XMKPF[] TO MEMORY ID 'CU09_MKPF'.
*
*              SUBMIT ZCREATE_MOV_957_937
*              AND RETURN WITH MBLNR EQ XMSEG-MBLNR
*                         WITH EBELN EQ XMSEG-EBELN
*                         WITH TCODE EQ SY-TCODE.
*
*              FREE MEMORY ID 'CU09_MKPF'.
*
*
*          ENDIF.

ENDENHANCEMENT.
