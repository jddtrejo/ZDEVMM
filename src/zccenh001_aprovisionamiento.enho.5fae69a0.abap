"Name: \PR:SAPLMR1M\FO:VARIANT_TRANSACTION\SE:BEGIN\EI
ENHANCEMENT 0 ZCCENH001_APROVISIONAMIENTO.

  IF RM08M-VORGANG EQ 2.
    IF  RBKPV-BELNR IS NOT INITIAL.
        DATA: it_ekko TYPE ekko OCCURS 0 WITH HEADER LINE.
        DATA: sysubrc TYPE sy-subrc.
        DATA: wa_t100 TYPE t100.
        DATA: l_mstring(480).
        DATA: s_mstring(480).
        DATA: stab TYPE STANDARD TABLE OF bdcmsgcoll,
              mtab TYPE bdcmsgcoll.

        DATA: bd_belns TYPE bdcdata-fval,
              bd_bukrs TYPE bdcdata-fval,
              bd_stgrd TYPE bdcdata-fval.

        LOOP AT T_EBELNTAB.
          SELECT *
            INTO CORRESPONDING FIELDS OF TABLE it_ekko
            FROM ekko
            WHERE ebeln EQ T_EBELNTAB-ebeln.

          READ TABLE it_ekko index 1.

          IF it_ekko-bsart EQ 'ZDV'.

            bd_belns = it_ekko-ebeln.
            bd_bukrs = it_ekko-bukrs.
            bd_stgrd = '02'. "12.06.2015 JLGF 4057 - Motivo Cambiar de 01 a 02

            CALL FUNCTION 'ZFB08_RECORD'
              EXPORTING
                belns   = bd_belns
                bukrs   = bd_bukrs
                stgrd   = bd_stgrd
              IMPORTING
                subrc   = sysubrc
              TABLES
                messtab = stab.

            LOOP AT stab INTO mtab.
              SELECT SINGLE * FROM t100 INTO wa_t100
               WHERE sprsl = mtab-msgspra
                 AND   arbgb = mtab-msgid
                 AND   msgnr = mtab-msgnr.

              IF sy-subrc = 0.
                l_mstring = wa_t100-text.
                IF l_mstring CS '&1'.
                  REPLACE '&1' WITH mtab-msgv1 INTO l_mstring.
                  REPLACE '&2' WITH mtab-msgv2 INTO l_mstring.
                  REPLACE '&3' WITH mtab-msgv3 INTO l_mstring.
                  REPLACE '&4' WITH mtab-msgv4 INTO l_mstring.
                ELSE.
                  REPLACE '&' WITH mtab-msgv1 INTO l_mstring.
                  REPLACE '&' WITH mtab-msgv2 INTO l_mstring.
                  REPLACE '&' WITH mtab-msgv3 INTO l_mstring.
                  REPLACE '&' WITH mtab-msgv4 INTO l_mstring.
                ENDIF.
                CONDENSE l_mstring.
                CONCATENATE mtab-msgtyp ',' l_mstring INTO l_mstring.
                "WRITE: l_mstring.
              ENDIF.
            ENDLOOP.

          ENDIF.
        ENDLOOP.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
