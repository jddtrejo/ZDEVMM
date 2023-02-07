"Name: \PR:SAPLMG21\FO:SPERREN_MARA\SE:BEGIN\EI
ENHANCEMENT 0 ZMMENH030_SPERREN.

  DATA: vl_intentos TYPE I.

  vl_intentos = 1.
  rcode = 1.
  While vl_intentos <= 5 and rcode eq 1.
    CLEAR sy-subrc.
    CASE sperrmodus.
      WHEN sperrmodus_s.
*   Shared Sperre
        CALL FUNCTION 'ENQUEUE_EMMARAS'
             EXPORTING
                  matnr          = mara_keytab-matnr
             EXCEPTIONS
                  foreign_lock   = 01
                  system_failure = 02.
        sperr_user = sy-msgv1.           "mk/3.0E
      WHEN sperrmodus_e.
*   Exclusive Sperre
        CALL FUNCTION 'ENQUEUE_EMMARAE'
             EXPORTING
                  matnr          = mara_keytab-matnr
             EXCEPTIONS
                  foreign_lock   = 01
                  system_failure = 02.
        sperr_user = sy-msgv1.           "mk/3.0E
    ENDCASE.
    rcode = sy-subrc.

    If rcode = 1.
       WAIT UP TO 20 SECONDS.
    Endif.
    Add 1 to vl_intentos.
  Endwhile.

  Exit.

ENDENHANCEMENT.
