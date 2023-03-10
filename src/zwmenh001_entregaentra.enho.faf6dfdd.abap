"Name: \PR:SAPLV50S\FO:GN_CREATE_REHANG_HU\SE:BEGIN\EI
ENHANCEMENT 0 ZWMENH001_ENTREGAENTRA.

  "07.12.2016 JLGF 5258
  IF SY-TCODE EQ 'ZMM095'.
    DATA: VL_LGNUM TYPE LIKP-LGNUM.
    READ TABLE XKOMDLGN INDEX 1.

    IF XKOMDLGN-RFBEL IS NOT INITIAL.
      SELECT SINGLE LGNUM
        INTO VL_LGNUM
        FROM LIKP
        WHERE VBELN EQ XKOMDLGN-RFBEL.

      IF SY-SUBRC EQ 0 AND VL_LGNUM IS NOT INITIAL.
        LOOP AT XLIKP.
          IF XLIKP-LGNUM IS INITIAL.
            XLIKP-LGNUM = VL_LGNUM.
            MODIFY XLIKP INDEX SY-TABIX.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  "07.12.2016 JLGF 5258

ENDENHANCEMENT.
