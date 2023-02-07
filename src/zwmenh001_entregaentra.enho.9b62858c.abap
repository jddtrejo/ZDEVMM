"Name: \FU:GN_DELIVERY_CREATE\SE:END\EI
ENHANCEMENT 0 ZWMENH001_ENTREGAENTRA.
*
    DATA: ld_pass TYPE likp-lfart.
    IMPORT ld_pass TO ld_pass FROM MEMORY ID 'PASS'.
    IF NOT ld_pass IS INITIAL.
      IF VBSK_E-ERNUM NE 0 AND " SI hay errores
         VBSK_E-VBNUM GT 0. " si hay EE
        DATA: ld_lines_input TYPE i,
              ld_lines_inb TYPE i.
        DESCRIBE TABLE XKOMDLGN[] LINES ld_lines_input.
        DESCRIBE TABLE XLIPS[] LINES ld_lines_inb.
        IF ld_lines_inb EQ ld_lines_input. " Se crearon bien
         CLEAR VBSK_E-ERNUM.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
    ENDIF.
ENDENHANCEMENT.
