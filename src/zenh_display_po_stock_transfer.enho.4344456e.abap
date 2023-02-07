"Name: \TY:/STWACS/CL_RELOCDOC_ADAPTER\IN:/STWACS/IF_RELOCDOC_ADAPTER\ME:REALEASE\SE:END\EI
ENHANCEMENT 0 ZENH_DISPLAY_PO_STOCK_TRANSFER.

    DATA: WA_EKKO TYPE EKKO.
    DATA: INT_EKPO  TYPE STANDARD TABLE OF MEPOITEM.
    DATA: INT_EKKO  TYPE STANDARD TABLE OF EKKO.
    DATA: V_CODE TYPE SY-TCODE.

    LW_MESSAGES-MSGTY = SR_INT_SERVICES->MSG_TYPE_SUCCESS.
    LW_MESSAGES-MSGID = 'ZMM01'.
    LW_MESSAGES-MSGNO = '048'.
    INSERT LW_MESSAGES INTO TABLE LT_MESSAGES.

    DO.
      SELECT SINGLE * INTO WA_EKKO FROM EKKO WHERE SUBMI EQ MS_HEADER_SAVED-SUBMISSION_NO.
      IF SY-SUBRC EQ 0.
        WAIT UP TO 5 SECONDS.
        EXIT.
      ENDIF.
    ENDDO.

    SELECT * INTO WA_EKKO FROM EKKO WHERE SUBMI EQ MS_HEADER_SAVED-SUBMISSION_NO.
      LW_MESSAGES-MSGTY = SR_INT_SERVICES->MSG_TYPE_SUCCESS.
      LW_MESSAGES-MSGID = 'EPM_WCF'.
      LW_MESSAGES-MSGNO = '000'.
      LW_MESSAGES-MSGV1 = WA_EKKO-EBELN.
      INSERT LW_MESSAGES INTO TABLE LT_MESSAGES.
    ENDSELECT.

    RAISE EVENT MESSAGES_TO_BE_ADDED
    EXPORTING
      I_MSG_LOG_TYPE = SR_INT_SERVICES->MSG_LOG_TYPE_RELOCDOC
      IT_MESSAGES    = LT_MESSAGES.


    CHECK SY-UCOMM EQ 'RELEASE'.

    SELECT * INTO TABLE INT_EKKO
    FROM EKKO
    WHERE SUBMI EQ MS_HEADER_SAVED-SUBMISSION_NO.

    LOOP AT INT_EKKO INTO WA_EKKO.
      IF WA_EKKO-BSART EQ 'ZSB'.
      V_CODE = SY-TCODE.
        CALL FUNCTION 'ZCREATE_IDOC_ORDERS_ZSB'
        EXPORTING
          EBELN       = WA_EKKO-EBELN
          BSART       = WA_EKKO-BSART
          TCODE       = V_CODE.
      ENDIF.
    ENDLOOP.
ENDENHANCEMENT.
