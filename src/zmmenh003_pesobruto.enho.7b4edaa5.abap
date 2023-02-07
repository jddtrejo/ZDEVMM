"Name: \FU:MEINH_BRGEW\SE:BEGIN\EI
ENHANCEMENT 0 ZMMENH003_PESOBRUTO.

  DATA: VL_HADDKO LIKE T006-ADDKO,        "Hilfsfeld für additive Konstante
        VL_Z_UMREN LIKE MARM-UMREN,       "Hilfsfeld
        VL_Z_UMREZ LIKE MARM-UMREZ,       "Hilfsfeld
*       HGEWICHT LIKE MARM-BRGEW.      "Hilfsfeld für Gewicht  "cfo/4.0C
        VL_HGEWICHT TYPE F,               "Hilfsfeld für Gewicht  "cfo/4.0C
        VL_SUBRC TYPE SY-SUBRC.

  CHECK NOT BME_NTGEW IS INITIAL.
  CHECK NOT UMREZ IS INITIAL AND NOT UMREN IS INITIAL.

  IF BME_GEWEI NE AME_GEWEI.
    CALL FUNCTION 'CONVERSION_FACTOR_GET'              "09.08.94 / CH
         EXPORTING
              UNIT_IN              = BME_GEWEI
              UNIT_OUT             = AME_GEWEI
         IMPORTING
              ADD_CONST            = VL_HADDKO
*             DENOMINATOR          = Z_UMREZ     ch zu 3.0d
*             NUMERATOR            = Z_UMREN
              DENOMINATOR          = UMREZ_F
              NUMERATOR            = UMREN_F
         EXCEPTIONS
              OTHERS               = 01.
    IF SY-SUBRC = 0.                              "ch zu 3.0d
      CALL FUNCTION 'CONVERT_TO_FRACT5'
           EXPORTING
                NOMIN               =  UMREZ_F
                DENOMIN             =  UMREN_F
           IMPORTING
                NOMOUT              =  VL_Z_UMREZ
                DENOMOUT            =  VL_Z_UMREN
           EXCEPTIONS
                OTHERS              = 01.
    ENDIF.
  ELSE.
    VL_Z_UMREZ = VL_Z_UMREN = 1.
    SY-SUBRC = 0.
  ENDIF.
  IF SY-SUBRC = 0.
    VL_HGEWICHT = UMREZ / UMREN * BME_NTGEW * VL_Z_UMREN / VL_Z_UMREZ.
    CATCH SYSTEM-EXCEPTIONS CONVT_OVERFLOW = 5.        "cfo/4.0C
      AME_NTGEW = VL_HGEWICHT.       "cfo/20.9.96 Rückgabe NTGEW
    ENDCATCH.                                         "cfo/4.0C
    IF SY-SUBRC NE 5.                                 "note 388879
      IF AME_BRGEW < AME_NTGEW AND NOT AME_BRGEW IS INITIAL.
        "note 1919570
        CALL FUNCTION 'ME_CHECK_T160M'
          EXPORTING
            I_ARBGB = 'M3'
            I_MSGNR = '176'
            I_MSGVS = '00'           " Messagevariante default '00'
            I_MSGTP_DEFAULT = 'W'
          EXCEPTIONS
            NOTHING     = 00
            ERROR       = 01
            WARNING     = 02.
        VL_SUBRC = SY-SUBRC. "17.02.2017 JLGF 5398

        IF SY-TCODE EQ 'MM41' OR SY-TCODE EQ 'MM42' OR SY-TCODE EQ 'MM43'.
          "17.02.2017 JLGF 5398 - INI
          CASE VL_SUBRC.
            WHEN 1.
              MESSAGE E176.
            WHEN 2.
              MESSAGE W176.
          ENDCASE.
          "17.02.2017 JLGF 5398 - FIN
        ELSE.
          IF VL_SUBRC = 0.
          ELSEIF VL_SUBRC = 2 OR VL_SUBRC = 1.
            CASE P_MESSAGE.        "cfo/19.07.95/nicht bei leerem BGEW
              WHEN ' '.
                MESSAGE W176.  "Bruttogewicht ist kleiner als Nettogewicht
            WHEN 'I'.
              MESSAGE I176.
            WHEN 'N'.
          ENDCASE.
        ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF AME_BRGEW < VL_HGEWICHT AND NOT AME_BRGEW IS INITIAL.
        "note 1919570
        CALL FUNCTION 'ME_CHECK_T160M'
          EXPORTING
            I_ARBGB = 'M3'
            I_MSGNR = '176'
            I_MSGVS = '00'           " Messagevariante default '00'
            I_MSGTP_DEFAULT = 'W'
          EXCEPTIONS
            NOTHING     = 00
            ERROR       = 01
            WARNING     = 02.
        VL_SUBRC = SY-SUBRC. "17.02.2017 JLGF 5398

        IF SY-TCODE EQ 'MM41' OR SY-TCODE EQ 'MM42' OR SY-TCODE EQ 'MM43'.
          "17.02.2017 JLGF 5398 - INI
          CASE VL_SUBRC.
            WHEN 1.
              MESSAGE E176.
            WHEN 2.
              MESSAGE W176.
          ENDCASE.
          "17.02.2017 JLGF 5398 - FIN
        ELSE.
          IF VL_SUBRC = 0.

          ELSEIF VL_SUBRC = 2 OR VL_SUBRC = 1.
            CASE P_MESSAGE.           "cfo/19.07.95/nicht bei leerem BGEW
              WHEN ' '.
                MESSAGE W176.  "Bruttogewicht ist kleiner als Nettogewicht
          WHEN 'I'.
            MESSAGE I176.
          WHEN 'N'.
        ENDCASE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  EXIT.

ENDENHANCEMENT.
