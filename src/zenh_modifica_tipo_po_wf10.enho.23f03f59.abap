"Name: \PR:SAPLWFR3\FO:DETERMINE_BSART_NEW\SE:END\EI
ENHANCEMENT 0 ZENH_MODIFICA_TIPO_PO_WF10.
    DATA: WA_MARA LIKE MARA.
    IF C_ITEM-BUKRS EQ 'SELE'.
      C_ITEM-BSART = 'ZLCO'.
    ELSE.
      SELECT SINGLE * FROM MARA INTO WA_MARA WHERE MATNR EQ C_ITEM-MATNR.
      IF WA_MARA-MTART EQ 'ZCIN'.
        C_ITEM-BSART = 'ZCIN'.
      ELSE.
        C_ITEM-BSART = 'ZCOL'.
      ENDIF.
    ENDIF.
ENDENHANCEMENT.
