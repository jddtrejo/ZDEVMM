"Name: \IC:MM06EFET_ETT_FUELLEN\EX:ETT_FUELLEN_01\EI
ENHANCEMENT 0 ZENH_MEMASSPO5.
IF SY-CPROG EQ 'MASSBACK'
OR SY-TCODE EQ 'MASS'.
  EXIT.
  ENDIF.
ENDENHANCEMENT.
