"Name: \FU:MRMBADI_CUST_FIELD_MODIFY\SE:END\EI
ENHANCEMENT 0 ZMRMBADI_CUST_FIELD_MODIFY.

****************************************************
* Declaracion de Variables
****************************************************

    DATA: TL_DRSEG     TYPE STANDARD TABLE OF ZMMES_001,
          TL_TDELE     TYPE MMCR_TDRSEG, " Tabla para Borrar Registrso con Cantidades
          SL_DRSEG     LIKE LINE OF TL_DRSEG, " Work Area
          SL_DRSEG_ORI LIKE LINE OF TI_DRSEG, " Work Area Original
          VL_MENGE     TYPE ZMMES_001-MENGE1,
          VL_IMPPROV   TYPE DRSEG-RBWWR,
          VL_VAR       TYPE C LENGTH 30.

    FIELD-SYMBOLS:  <FS_DIFF>  TYPE RM08M-DIFFERENZ.

    TL_TDELE[] = TE_DRSEG[].

    DELETE TL_TDELE WHERE MENGE NE 0 OR WRBTR NE 0.
    DELETE TE_DRSEG WHERE MENGE EQ 0 OR WRBTR EQ 0.

    CALL FUNCTION 'ZMMFM_MIRO_GET_DATA'
    IMPORTING
      EX_IMPPROV = VL_IMPPROV
    TABLES
      EX_DRSEG   = TL_DRSEG.



*    IF SY-UNAME EQ 'GJUAREZ'.
      VL_VAR = '(SAPLMR1M)RM08M-DIFFERENZ'.
      ASSIGN (VL_VAR) TO <FS_DIFF>.
      <FS_DIFF> = VL_IMPPROV.

*qajm  06.05.2022
    export  VL_IMPPROV TO MEMORY ID 'ZSALDO'.

  BREAK DEV_EXTERNO.
*    ELSE.
*      IF 1 = 2.
*        VL_VAR = '(SAPLMR1M)RM08M-DIFFERENZ'.
*        ASSIGN (VL_VAR) TO <FS_DIFF>.
*        <FS_DIFF> = VL_IMPPROV.
*      ENDIF.
*    ENDIF.

*****************************************************************
* Se Verifica que no se haya desmarcado una de las posiciones
*****************************************************************

    LOOP AT TL_DRSEG INTO SL_DRSEG.
      LOOP AT TE_DRSEG INTO SL_DRSEG_ORI WHERE EBELN = SL_DRSEG-EBELN
                                           AND EBELP = SL_DRSEG-EBELP.
        SL_DRSEG_ORI-SELKZ = SL_DRSEG-SELKZ.
        SL_DRSEG_ORI-MWSKZ = SL_DRSEG-MWSKZ.
        SL_DRSEG_ORI-KZMEK = SL_DRSEG-KZMEK.
        SL_DRSEG_ORI-MENGE = SL_DRSEG_ORI-WEMNG.

        IF SL_DRSEG_ORI-SELKZ =  'X'.
          IF SL_DRSEG-KZMEK IS INITIAL.
*            SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ) * SL_DRSEG_ORI-BPUMZ.
            SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ). "* SL_DRSEG_ORI-BPUMZ. ajm 02.06.2022
          ENDIF.
        ENDIF.

        IF SL_DRSEG-KZMEK IS NOT INITIAL.
          IF ( ( SL_DRSEG-NETPR < SL_DRSEG-NETPR2 ) OR ( SL_DRSEG-MENGE1 > SL_DRSEG-MENGE2 ) ).
            SL_DRSEG_ORI-WRBTR = SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE.
          ENDIF.

*           IF SL_DRSEG-NETPR > SL_DRSEG-NETPR2 .
*            SL_DRSEG_ORI-WRBTR = SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE.
*          ENDIF.


        ENDIF.

        CLEAR: SL_DRSEG_ORI-RBWWR, SL_DRSEG_ORI-RBMNG.
        MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
      ENDLOOP.
    ENDLOOP.


*    LOOP AT TL_DRSEG INTO SL_DRSEG.
*      LOOP AT TE_DRSEG INTO SL_DRSEG_ORI WHERE EBELN = SL_DRSEG-EBELN
*                                           AND EBELP = SL_DRSEG-EBELP.
*        IF SL_DRSEG-KZMEK IS NOT INITIAL.
*          IF ( ( SL_DRSEG-NETPR < SL_DRSEG-NETPR2 ) AND ( SL_DRSEG-MENGE1 > SL_DRSEG-MENGE2 ) ).
*            SL_DRSEG_ORI-WRBTR = SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE.
*          ENDIF.
*          MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.

********************************************************************
* Verificanmos que no haya Cambio en la Cantidad
********************************************************************
    LOOP AT TL_DRSEG INTO SL_DRSEG.

      IF SL_DRSEG-CMENGE =  '-'.
        SORT TE_DRSEG BY RBLGP ASCENDING.
        LOOP AT TE_DRSEG INTO SL_DRSEG_ORI WHERE EBELN = SL_DRSEG-EBELN
        AND EBELP = SL_DRSEG-EBELP.

          VL_MENGE = SL_DRSEG-MENGE1 - SL_DRSEG_ORI-MENGE.
          IF SL_DRSEG_ORI-MENGE <= SL_DRSEG-MENGE1.
            IF ( SL_DRSEG-KZMEK IS NOT INITIAL ) AND ( SL_DRSEG_ORI-MENGE = SL_DRSEG-MENGE1 ).
              SL_DRSEG_ORI-RBWWR = SL_DRSEG-RBWWR + SL_DRSEG_ORI-WRBTR.
              SL_DRSEG_ORI-RBMNG = SL_DRSEG-MENGE1.
              MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
            ENDIF.
            SL_DRSEG-MENGE1    = VL_MENGE.
            MODIFY TL_DRSEG FROM SL_DRSEG.
          ELSE.
            IF SL_DRSEG-MENGE1 > 0.
              SL_DRSEG_ORI-MENGE = SL_DRSEG-MENGE1.
              IF SL_DRSEG_ORI-SELKZ = 'X'.
                IF SL_DRSEG-KZMEK IS NOT INITIAL.
                  SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR2 * SL_DRSEG_ORI-MENGE ).
                  SL_DRSEG_ORI-RBWWR = SL_DRSEG-RBWWR + SL_DRSEG_ORI-WRBTR.
                  SL_DRSEG_ORI-RBMNG = SL_DRSEG-MENGE1.
                ELSE.
                  SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ).
                ENDIF.
              ELSE.
                SL_DRSEG_ORI-MENGE = SL_DRSEG_ORI-WEMNG.

                IF SL_DRSEG-KZMEK IS NOT INITIAL.
                  SL_DRSEG_ORI-RBWWR = SL_DRSEG-RBWWR + SL_DRSEG_ORI-WRBTR.
                  SL_DRSEG_ORI-RBMNG = SL_DRSEG-MENGE1.
                  SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR2 * SL_DRSEG_ORI-MENGE ).
                ELSE.
                  SL_DRSEG_ORI-WRBTR = ( SL_DRSEG_ORI-NETPR * SL_DRSEG_ORI-WEMNG ).
                ENDIF.

              ENDIF.
              MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
            ELSE.
              IF SL_DRSEG-KZMEK IS NOT INITIAL AND SL_DRSEG-MENGE1 > 0.
                SL_DRSEG_ORI-RBWWR = SL_DRSEG-RBWWR + SL_DRSEG_ORI-WEWWR.
                SL_DRSEG_ORI-RBMNG = SL_DRSEG-RBMNG + SL_DRSEG_ORI-BPMNG.
                SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR2 * SL_DRSEG_ORI-WEMNG ).
              ELSE.
                SL_DRSEG_ORI-WRBTR = ( SL_DRSEG-NETPR * SL_DRSEG_ORI-WEMNG ).
              ENDIF.
              SL_DRSEG_ORI-MENGE = SL_DRSEG_ORI-WEMNG.
              SL_DRSEG_ORI-SELKZ = SPACE.
              MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
            ENDIF.
            SL_DRSEG-MENGE1 = VL_MENGE.
            MODIFY TL_DRSEG FROM SL_DRSEG.
          ENDIF.
        ENDLOOP.


    ELSEIF SL_DRSEG-CMENGE =  '+'.

        SORT TE_DRSEG BY RBLGP DESCENDING.
        LOOP AT TE_DRSEG INTO SL_DRSEG_ORI
        WHERE EBELN = SL_DRSEG-EBELN
        AND EBELP = SL_DRSEG-EBELP.

          IF SL_DRSEG-KZMEK IS INITIAL.
            SL_DRSEG_ORI-MENGE = SL_DRSEG_ORI-MENGE + SL_DRSEG-MENGER.
*            SL_DRSEG_ORI-WRBTR = ( ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ) * SL_DRSEG_ORI-BPUMZ ).
*            SL_DRSEG_ORI-RBWWR = ( ( SL_DRSEG-NETPR * SL_DRSEG-MENGER ) * SL_DRSEG_ORI-BPUMZ ).
            SL_DRSEG_ORI-WRBTR =   ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ). " * SL_DRSEG_ORI-BPUMZ ).  @ajm 02.06.2022
            SL_DRSEG_ORI-RBWWR =   ( SL_DRSEG-NETPR * SL_DRSEG-MENGER ).     "* SL_DRSEG_ORI-BPUMZ ).  @ajm 02.06.2022
            SL_DRSEG_ORI-RBMNG = SL_DRSEG-MENGER.
            MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
            EXIT.
          ELSE.
            IF  SL_DRSEG-RBMNG > 0
            AND SL_DRSEG-RBWWR > 0.
              SL_DRSEG_ORI-RBMNG = SL_DRSEG-MENGER + SL_DRSEG_ORI-MENGE.
              "INICIO MODIFICACION 30.07.2018 "LO QUE REQUERIMOS ES QUE SE TOME EL MONTO TOTAL DE LA DIFERENCIA Y SE SUME AL MONTO DE LA POSICIÓN:
              IF SL_DRSEG-KZMEK IS NOT INITIAL.
                IF ( ( SL_DRSEG-NETPR < SL_DRSEG-NETPR2 ) AND ( SL_DRSEG-MENGE1 > SL_DRSEG-MENGE2 ) ).
                  ""SL_DRSEG_ORI-RBWWR = SL_DRSEG_ORI-WRBTR + SL_DRSEG-RBWWR.
                  SL_DRSEG_ORI-RBWWR = ( SL_DRSEG_ORI-MENGE * SL_DRSEG-NETPR ) + SL_DRSEG-RBWWR.
                ELSE.
                  SL_DRSEG_ORI-RBWWR = SL_DRSEG_ORI-WEWWR + SL_DRSEG-RBWWR.
                ENDIF.
                "FIN MODIFICACION 30.07.2018 "LO QUE REQUERIMOS ES QUE SE TOME EL MONTO TOTAL DE LA DIFERENCIA Y SE SUME AL MONTO DE LA POSICIÓN:
              ELSE.
*                SL_DRSEG_ORI-RBWWR = ( ( SL_DRSEG-NETPR * ( SL_DRSEG-MENGER + SL_DRSEG_ORI-MENGE ) ) * SL_DRSEG_ORI-BPUMZ ).
                SL_DRSEG_ORI-RBWWR =   ( SL_DRSEG-NETPR * ( SL_DRSEG-MENGER + SL_DRSEG_ORI-MENGE ) ). "* SL_DRSEG_ORI-BPUMZ ). @ajm 02.06.2022
              ENDIF.
              MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
              EXIT.
            ENDIF.
            IF  SL_DRSEG-RBMNG = 0
            AND SL_DRSEG-RBWWR > 0.
              SL_DRSEG_ORI-RBMNG = SL_DRSEG_ORI-MENGE.
*             SL_DRSEG_ORI-RBWWR = ( ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ) * SL_DRSEG_ORI-BPUMZ ).
              SL_DRSEG_ORI-RBWWR =  ( SL_DRSEG-NETPR * SL_DRSEG_ORI-MENGE ). " * SL_DRSEG_ORI-BPUMZ ). @ajm 02.06.2022
              SL_DRSEG_ORI-LIEFFN = SL_DRSEG_ORI-RBWWR - SL_DRSEG_ORI-NETWR.  "@AJM 25.05.2022
              MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.


*    IF SY-UNAME NE 'GJUAREZ'.
*      LOOP AT TE_DRSEG INTO SL_DRSEG_ORI.
*        IF SL_DRSEG_ORI-KZMEK NE SPACE.
*          IF SL_DRSEG_ORI-RBWWR NE 0.
*            SL_DRSEG_ORI-LIEFFN = SL_DRSEG_ORI-RBWWR - SL_DRSEG_ORI-WRBTR.
*            SL_DRSEG_ORI-XUPDA  = 'X'.
*            SL_DRSEG_ORI-BPRBM  = SL_DRSEG_ORI-BPMNGALT.
*            SL_DRSEG_ORI-EFKOR  = '1'.
*          ELSE.
*            CLEAR SL_DRSEG_ORI-KZMEK.
*          ENDIF.
*          MODIFY TE_DRSEG FROM SL_DRSEG_ORI.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.



    IF TL_TDELE[] IS NOT INITIAL.
      APPEND LINES OF TL_TDELE TO TE_DRSEG.
    ENDIF.
    SORT TE_DRSEG BY RBLGP EBELN EBELP ASCENDING.

"@AJM  BEGIN 25.05.2022
*    DATA:   betrag1_c(16) TYPE c,
*           betrag2_c(16) TYPE c.
*
*    loop at TE_DRSEG into  SL_DRSEG_ORI WHERE  LIEFFN ne 0.
*
*       WRITE SL_DRSEG_ORI-lieffn TO betrag1_c CURRENCY SL_DRSEG_ORI-waers.
*       CONDENSE betrag1_c.
*
*     CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*      EXPORTING
*      i_arbgb = 'M8'
*      i_dtype = c_msgty_info
*      i_msgnr = '598'
*      i_var01 = betrag1_c
*      i_var02 = SL_DRSEG_ORI-waers
*      i_var03 = betrag1_c.
*       IF 1 = 0.
*          MESSAGE i598 WITH betrag1_c SL_DRSEG_ORI-waers betrag1_c.
*       ENDIF.
*       exit.
*    ENDLOOP.


"@AJM  END 25.05.2022



ENDENHANCEMENT.
