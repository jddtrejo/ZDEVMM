"Name: \PR:SAPLWST1\FO:CONTROL_DATA_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 ZMMENH004_VALIDACANT.
BREAK JDDTREJO.
data:ls_message2      type lmess,
     WA_MARA TYPE MARA.

  IF SY-TCODE EQ 'MM42' OR SY-TCODE EQ 'MM41'.
    IF p_wstr_dynp-CPQTY  <= 0  OR p_wstr_dynp-CPQTY > 9999.
*      SELECT SINGLE * FROM MARA INTO WA_MARA WHERE MATNR EQ P_GS_DATA-MATNR AND ATTYP EQ '10'.
*      IF SY-SUBRC EQ 0.
      ls_message2-msgid = '00'.
      ls_message2-msgty = 'E'.
      ls_message2-msgno = 398.
      ls_message2-msgv1 = 'La cantidad capturada no puede ser menor a 1 '.
      ls_message2-msgv2 = 'ni mayor a 9999'.
      message id     ls_message2-msgid
              type   ls_message2-msgty
              number ls_message2-msgno
              with   ls_message2-msgv1 ls_message2-msgv2 '' ''.
*      ENDIF.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
