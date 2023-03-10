"Name: \FU:IDOC_INPUT_COND_A\SE:END\EI
ENHANCEMENT 0 ZENHO_DETERMINACION_PRECIO.
    DATA: WA_PRICE_CALC LIKE ZCTRL_PRICE_CALC.
    DATA: WA_CONVENIOS  LIKE ZMATNR_CONVENIOS.
    DATA: WA_MARA       LIKE MARA.
    DATA: V_DIAS TYPE I.
    DATA: WA_ERROR_CONDA TYPE ZERROR_COND_A.
    DATA: WA_STATUS LIKE BDIDOCSTAT.

    IF S_KOMG-VTWEG EQ 'C5'.

      READ TABLE IDOC_STATUS WITH KEY MSGTY = 'E'.
      IF SY-SUBRC NE 0.
        READ TABLE T_KONH INDEX 1.
        IF T_KONH-KSCHL EQ  'VKP0'.
          IF T_KONH-KOTABNR EQ '073'.
            GET TIME.
            MOVE T_KONH-VAKEY TO WA_PRICE_CALC-VAKEY.
            MOVE T_KONH-DATAB TO WA_PRICE_CALC-DATAB.
            MOVE T_KONH-DATBI TO WA_PRICE_CALC-DATBI.
            MOVE T_KONH-KOTABNR TO WA_PRICE_CALC-KOTABNR.
            MOVE SY-DATUM     TO WA_PRICE_CALC-DATUM.
            MOVE SY-UZEIT     TO WA_PRICE_CALC-UZEIT.
            MOVE SY-UNAME     TO WA_PRICE_CALC-UNAME.
            MODIFY ZCTRL_PRICE_CALC FROM WA_PRICE_CALC.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE T_KONH INDEX 1.
    IF T_KONH-KSCHL EQ 'ZPB0'.
      READ TABLE IDOC_STATUS WITH KEY MSGTY = 'E'.
      IF SY-SUBRC NE 0.
        SELECT SINGLE * INTO WA_MARA FROM MARA WHERE MATNR EQ S_KOMG-MATNR.
        V_DIAS = SY-DATUM - WA_MARA-ERSDA.
        IF V_DIAS LE 7.
          GET TIME.
          MOVE S_KOMG-MATNR     TO WA_CONVENIOS-MATNR.
          MOVE WA_MARA-MATKL(3) TO WA_CONVENIOS-DEPTO.
          MOVE S_KOMG-LIFNR     TO WA_CONVENIOS-LIFNR.
          MOVE S_KOMG-EKORG     TO WA_CONVENIOS-EKORG.
          MOVE SY-DATUM         TO WA_CONVENIOS-DATUM.
          MOVE SY-UZEIT         TO WA_CONVENIOS-UZEIT.
          MODIFY ZMATNR_CONVENIOS FROM WA_CONVENIOS.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDIF.


    READ TABLE IDOC_STATUS INTO WA_STATUS WITH KEY MSGTY = 'E'.
    IF SY-SUBRC EQ 0.
      MOVE IDOC_STATUS-DOCNUM TO WA_ERROR_CONDA-DOCNUM.
      MOVE IDOC_STATUS-STATUS TO WA_ERROR_CONDA-STATUS.
      MOVE S_KOMG-MATNR       TO WA_ERROR_CONDA-MATNR.
      MOVE SY-DATUM           TO WA_ERROR_CONDA-DATUM.

*DATA LANGUAGE TYPE T100-SPRSL.
*DATA MSG_ID   TYPE T100-ARBGB.
*DATA MSG_NO   TYPE T100-MSGNR.
*DATA MSG_VAR1 TYPE BALM-MSGV1.
*DATA MSG_VAR2 TYPE BALM-MSGV2.
*DATA MSG_VAR3 TYPE BALM-MSGV3.
*DATA MSG_VAR4 TYPE BALM-MSGV4.

      CALL FUNCTION 'MESSAGE_PREPARE'
      EXPORTING
*         LANGUAGE                     = ' '
        MSG_ID                       = IDOC_STATUS-MSGID
        MSG_NO                       = IDOC_STATUS-MSGNO
        MSG_VAR1                     = IDOC_STATUS-MSGV1
        MSG_VAR2                     = IDOC_STATUS-MSGV2
        MSG_VAR3                     = IDOC_STATUS-MSGV3
        MSG_VAR4                     = IDOC_STATUS-MSGV4
      IMPORTING
        MSG_TEXT                     = WA_ERROR_CONDA-MESSAGE
      EXCEPTIONS
        FUNCTION_NOT_COMPLETED       = 1
        MESSAGE_NOT_FOUND            = 2
        .

      MODIFY ZERROR_COND_A FROM WA_ERROR_CONDA.
      COMMIT WORK.
    ENDIF.
ENDENHANCEMENT.
