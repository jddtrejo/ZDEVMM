"Name: \PR:SAPLWBBY_GENERAL\FO:MATGRPG_GET_MATERIAL\SE:END\EI
ENHANCEMENT 0 ZENH_LIMITED_ARTICLES_VBK1.
    DATA: V_LINES TYPE I.
    IF SY-TCODE EQ 'VBK1'
    AND PT_KONMATGRPP-POSTYPE EQ 'MCA'.
      DESCRIBE TABLE PT_MATERIAL_TMP LINES V_LINES.
      IF V_LINES GT 9999.
        DELETE PT_MATERIAL_TMP FROM 9000 TO V_LINES.
      ENDIF.
    ENDIF.
ENDENHANCEMENT.
