"Name: \PR:RWDBBMAN_HPR\FO:IDOC_CREATE\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_DEPURE_OV10_C5.
 DATA: I_ARTNR          TYPE TST_ALLFILIA.
 DATA: WA_MVKE TYPE MVKE.

    LOOP AT G_T_ARTNR INTO I_ARTNR.
      SELECT SINGLE * INTO WA_MVKE FROM MVKE WHERE MATNR EQ I_ARTNR-ARTNR
      AND VKORG EQ 'OV10'
      AND VTWEG EQ 'C5'
      AND KTGRM EQ '01'.
      IF SY-SUBRC NE 0.
        DELETE G_T_ARTNR.
      ENDIF.
    ENDLOOP.
ENDENHANCEMENT.
