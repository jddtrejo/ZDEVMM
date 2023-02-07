"Name: \PR:SAPLV61A\FO:USEREXIT_XKOMV_BEWERTEN_INIT\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_VALIDA_MARGE_PV1.
    " VALIDACION DE MARGEN DE PRECIO DE VENTA.
    DATA: V_KBETR TYPE KBETR,
          O_KBETR TYPE KBETR,
          V_LEN TYPE I,
          V_STR(15) TYPE C,
          V_EKPNN TYPE CALP-EKPNN,
          LT_A018 TYPE STANDARD TABLE OF A018,
          LT_KONP TYPE STANDARD TABLE OF KONP WITH HEADER LINE,
          MARGEN TYPE P DECIMALS 2,
          V_MATKL TYPE ZMARGEN_GPOART-GPOAR,
          WA_MARGEN TYPE ZMARGEN_GPOART,
          XARBFELD(15) TYPE C,
          MESID TYPE C,
          MESS TYPE ZDATA,
          V_FLAG TYPE C,
          RETCODE TYPE  CHAR1,
          P_DATE TYPE  BUDAT,
          MESSAGE TYPE  BAPI_MSG,
          V_WERKS TYPE MARD-WERKS,
          V_MTART TYPE MTART,
          V_LIFNR TYPE LIFNR.

    DATA:  BEGIN OF G_T_XERRO  OCCURS 0.
      INCLUDE STRUCTURE ERRO.
    DATA:  END OF G_T_XERRO.

    DATA: P_TIME TYPE T VALUE '000002',
          L_HORA TYPE T,
          L_FECHA TYPE D.
    DATA: L_NUMERO(8).
    DATA: L_JOBNAME TYPE BTCJOB.

    CONSTANTS: SI TYPE C VALUE 'X'.

    RANGES: R_WERKS FOR V_WERKS.

    IF SY-UCOMM EQ 'BUCH' OR SY-UCOMM EQ 'ZURU'.
      SELECT SINGLE MTART FROM MARA
      INTO V_MTART
      WHERE MATNR EQ COMM_ITEM_I-MATNR.

      CHECK V_MTART EQ 'ZMER'.

      CHECK ARBFELD NE 0 OR ARBFELD IS NOT INITIAL.

      MOVE ARBFELD TO XARBFELD.

      IF COMM_ITEM_I-MATNR IS INITIAL.
        MOVE '1101' TO V_WERKS.
      ELSE.
        MOVE COMM_ITEM_I-MATNR TO V_WERKS.
      ENDIF.

      CALL FUNCTION 'ZOBTIENE_COSTO_CON_DESCUENTOS'
      EXPORTING
        MATNR   = COMM_ITEM_I-MATNR
        LIFNR   = COMM_HEAD_I-LIFNR
        WERKS   = V_WERKS
        ARBFELD = XARBFELD
      IMPORTING
        EKPNN   = V_EKPNN
        KBETR   = O_KBETR
        MESID   = MESID
        MESS    = MESS.

      "OBTIENE MARGEN.
      IF O_KBETR > 0.
        MARGEN =  ( ( ( O_KBETR - V_EKPNN ) * 100 ) / O_KBETR ) * 100.
*       MARGEN = ( MARGEN * 100 ) / O_KBETR.
*       MARGEN = MARGEN * 100.
      ENDIF.

      SELECT SINGLE MATKL INTO V_MATKL
      FROM MARA
      WHERE MATNR EQ COMM_ITEM_I-MATNR.

      SELECT SINGLE * FROM ZMARGEN_GPOART
      INTO WA_MARGEN
      WHERE GPOAR EQ V_MATKL.

      IF SY-SUBRC EQ 0.
        IF MARGEN GE WA_MARGEN-MAINI AND MARGEN LE WA_MARGEN-MAFIN.
*          "VALIDA SI TIENE INVENTARIO
*          FREE: R_WERKS.
*          MOVE: 'I' TO R_WERKS-SIGN,
*          'CP' TO R_WERKS-OPTION,
*          'CC*' TO R_WERKS-LOW.
*          APPEND R_WERKS.
*          MOVE: 'S*' TO R_WERKS-LOW.
*          APPEND R_WERKS.
*          MOVE: 'W*' TO R_WERKS-LOW.
*          APPEND R_WERKS.
*
*          SELECT SINGLE WERKS FROM MARD INTO V_WERKS
*          WHERE MATNR EQ COMM_ITEM_I-MATNR
*          AND WERKS IN R_WERKS
*          AND LGORT EQ 'A001'
*          AND LABST GT 0.
*          IF SY-SUBRC EQ 0.
*
*            SET PARAMETER ID 'ZMPV1' FIELD SI.
*
*            GET TIME.
*
*            CALL FUNCTION 'C14B_ADD_TIME'
*            EXPORTING
*              I_STARTTIME = SY-UZEIT
*              I_STARTDATE = SY-DATUM
*              I_ADDTIME   = P_TIME
*            IMPORTING
*              E_ENDTIME   = L_HORA
*              E_ENDDATE   = L_FECHA.
*
*            CONCATENATE 'VKU10' COMM_ITEM_I-MATNR
*            INTO L_JOBNAME SEPARATED BY SPACE.
**-----------------------------------------------+
** FUNCION DE EJECUCION EN FONDO PARA IDOC DISTRO|
**-----------------------------------------------+
*            CALL FUNCTION 'JOB_OPEN'
*            EXPORTING
*              JOBNAME          = L_JOBNAME
*              SDLSTRTDT        = L_FECHA
*              SDLSTRTTM        = L_HORA
*            IMPORTING
*              JOBCOUNT         = L_NUMERO
*            EXCEPTIONS
*              CANT_CREATE_JOB  = 1
*              INVALID_JOB_DATA = 2
*              JOBNAME_MISSING  = 3
*              OTHERS           = 4.
*
*            SUBMIT ZDSMMRE001_MPV1 AND RETURN
*            WITH P_MATNR = COMM_ITEM_I-MATNR
*            VIA JOB L_JOBNAME NUMBER L_NUMERO.
*
*            CALL FUNCTION 'JOB_CLOSE'
*            EXPORTING
*              JOBCOUNT             = L_NUMERO
*              JOBNAME              = L_JOBNAME
*              SDLSTRTDT            = L_FECHA
*              SDLSTRTTM            = L_HORA
*            EXCEPTIONS
*              CANT_START_IMMEDIATE = 1
*              INVALID_STARTDATE    = 2
*              JOBNAME_MISSING      = 3
*              JOB_CLOSE_FAILED     = 4
*              JOB_NOSTEPS          = 5
*              JOB_NOTEX            = 6
*              LOCK_FAILED          = 7
*              OTHERS               = 8.

*          CALL FUNCTION 'ZEJECUTA_VKU10'
*            EXPORTING
*              P_MATNR      = COMM_ITEM_I-MATNR
*            IMPORTING
*              RETCODE      = RETCODE
*              POSTING_DATE = P_DATE
*              MESSAGE      = MESSAGE.

*          CLEAR: RETCODE, P_DATE, MESSAGE.
*          IMPORT: RETCODE FROM MEMORY ID 'ZRETCODE',
*                  P_DATE FROM MEMORY ID 'ZPDATE',
*                  MESSAGE FROM MEMORY ID 'ZMESS'.

*          IF RETCODE EQ 0.
**           MESSAGE 'PRECIO DE VENTA MODIFICADO.' TYPE 'S'.
*          ELSE.
*            MESSAGE MESSAGE TYPE 'E'.
*          ENDIF.
*          ENDIF.
          "CONTINUA PROCESO
        ELSE.
          MESSAGE 'PRECIO DE VENTA FUERA DE MARGEN ESTABLECIDO.' TYPE 'E'.
          IF SY-UCOMM EQ 'ZURU'.
            LEAVE TO SCREEN 0.
          ELSE.
            STOP.
          ENDIF.
        ENDIF.

      ELSE.
        MESSAGE 'GRUPO ARTICULO NO CATALOGADO EN ZMARGEN_GPOART' TYPE 'E'.
      ENDIF.

    ENDIF.
ENDENHANCEMENT.
