"Name: \PR:SAPLMGMU\FO:WERK_BEARBEITEN\SE:BEGIN\EI
ENHANCEMENT 0 ZENH_LIMITED_REFERENZE_WERKS.

    IF SY-TCODE EQ 'MM41' OR SY-TCODE EQ 'MM42'.
      IF P_WERKS EQ 'RFSC'.
        READ TABLE REFPLANT_MATNR_GES INDEX 1.
        IF SY-SUBRC EQ 0.
          DELETE REFPLANT_MATNR_GES.
        ENDIF.
        EXIT.
      ENDIF.
    ENDIF.

ENDENHANCEMENT.