"Name: \PR:SAPLMR1M\FO:DIFFERENZ_BERECHNEN\SE:END\EI
ENHANCEMENT 0 Z1_SALDO_MIRO.
*
    DATA: VL_IMPPROV   TYPE DRSEG-RBWWR.


  BREAK DEV_EXTERNO.

  IMPORT  VL_IMPPROV from MEMORY ID 'ZSALDO'.

   IF VL_IMPPROV NE 0.
      RM08M-DIFFERENZ = VL_IMPPROV.
   ENDIF.


ENDENHANCEMENT.