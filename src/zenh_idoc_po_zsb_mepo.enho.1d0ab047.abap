"Name: \PR:SAPLMEPO\FO:PARAMETER_SETZEN\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_IDOC_PO_ZSB_MEPO.

 DATA: V_CODE TYPE SY-TCODE.

    CHECK SY-UCOMM EQ 'OPT1'
    OR SY-UCOMM EQ 'MESAVE'.

    IF EKKO-BSART EQ 'ZSB'.

      WAIT UP TO 1 SECONDS.

        V_CODE = SY-TCODE.

        CALL FUNCTION 'ZCREATE_IDOC_ORDERS_ZSB'
        EXPORTING
          EBELN       = EKKO-EBELN
          BSART       = EKKO-BSART
          TCODE       = V_CODE.

    ENDIF.

ENDENHANCEMENT.
