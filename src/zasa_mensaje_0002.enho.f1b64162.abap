"Name: \PR:SAPLWBQF\FO:FUNCTION_NORMAL\SE:END\EI
ENHANCEMENT 0 ZASA_MENSAJE_0002.
    DATA: V_CODE TYPE TCODE.
    GET PARAMETER ID '&%ZAA' FIELD V_CODE.

    IF V_CODE EQ 'ZASA'
    AND UP_AUFI-PMNGU IS INITIAL
    AND UT_MESSG-MSGNO EQ '485'.
      DELETE UT_MESSG WHERE MSGNO = '485'.
    ENDIF.

ENDENHANCEMENT.