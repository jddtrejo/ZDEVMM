"Name: \PR:SAPLBAPIS1068\FO:CHECK_DISCOUNTS\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_HEADER_PROMO_KSCHL_PERC.

    FIELD-SYMBOLS: <DISCOUNTS>          TYPE BAPI1068T31.

    LOOP AT IT_DISCOUNTS ASSIGNING <DISCOUNTS>.
      IF  <DISCOUNTS>-MATL_GROUP IS NOT INITIAL.
        MOVE 'ZGPA' TO XS_NEWPROMO_HEADER-KSCHL_PERC.
        EXIT.
      ENDIF.
    ENDLOOP.

ENDENHANCEMENT.