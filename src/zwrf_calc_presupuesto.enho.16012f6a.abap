"Name: \PR:SAPLWRF_PPW03\FO:PRICE_DIFF_CALCULATE\SE:END\EI
ENHANCEMENT 0 ZWRF_CALC_PRESUPUESTO.

*El precio Old es aquel precio final que esta antes de realizarce la rebaja(Osea el precio final actual)
*El precio nuevo es el precio que esta despues de realizarce la rebaja sobre el precio original
*Como nuestro precio Old no estara cambiando , debemos verificar si hay un descuento de una rebaja existente y restarla al precio viejo
*

    DATA:DIFFERENCE TYPE WRF_PPW_BUDGET_VP,
          OLD_PRICE TYPE WRF_PPW_BUDGET_VP.


    CALL FUNCTION 'ZWRF_GET_DISCOUNT'
    EXPORTING
      DATOS            = LW_PPDPA_NEW
    IMPORTING
      DIFERENCIA       = DIFFERENCE
    EXCEPTIONS
      1                = 1
      OTHERS           = 2
      .

    PE_PRICE_DIFF = DIFFERENCE.

ENDENHANCEMENT.
