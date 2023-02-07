"Name: \FU:IDOC_INPUT_ARTMAS\SE:END\EI
ENHANCEMENT 0 ZENH_FILL_MARC_Z.
  DATA: HEAD(100)       TYPE C,
        STRING(770)     TYPE C,
        L_BIG_HEAD      LIKE STRING,
        GD_SEPARATOR(1) TYPE C VALUE '|',
        I_NEWVALUE(10),
        I_CHANGEFIELD(20).


  IF IDOC_STATUS-STATUS EQ '53'.

      LOOP AT IDOC_DATA.
        IF IDOC_DATA-SEGNAM EQ  'E1BPE1WLK2EXTRT'.
          E1BPE1WLK2EXTRT = IDOC_DATA-SDATA.
          IF E1BPE1WLK2EXTRT-FIELD1 IS NOT INITIAL.

            MOVE E1BPE1WLK2EXTRT-FIELD1 TO STRING.

            DO.
              IF STRING EQ ''.
                EXIT.
              ENDIF.

              L_BIG_HEAD = HEAD.

              CALL FUNCTION 'STRING_SPLIT'
              EXPORTING
                DELIMITER = GD_SEPARATOR
                STRING    = STRING
              IMPORTING
                HEAD      = L_BIG_HEAD
                TAIL      = STRING
              EXCEPTIONS
                NOT_FOUND = 1
                NOT_VALID = 2
                TOO_LONG  = 3
                TOO_SMALL = 4.

              CASE SY-SUBRC.
              WHEN 1.
                HEAD = STRING.
                CLEAR STRING.
              WHEN OTHERS.                                           "note 529355
                HEAD = L_BIG_HEAD.                                   "note 529355
              ENDCASE.


              SPLIT HEAD AT '-' INTO I_CHANGEFIELD I_NEWVALUE.

              CALL FUNCTION 'ZCHANGE_ARTMAS_FIELDS_WLK2'
              EXPORTING
                I_TABLE             = 'WLK2'
                I_STRUCTURE         = 'WLK2'
                I_MATNR             = E1BPE1WLK2EXTRT-MATERIAL
                I_VKORG             = E1BPE1WLK2EXTRT-SALES_ORG
                I_VTWEG             = E1BPE1WLK2EXTRT-DISTR_CHAN
                I_WERKS             = E1BPE1WLK2EXTRT-PLANT
                I_NEWVALUE          = I_NEWVALUE
                I_CHANGEFIELD       = I_CHANGEFIELD
          .

            ENDDO.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DATA: VL_NEWVALUE TYPE CHAR10.

      LOOP AT IDOC_DATA.
        IF IDOC_DATA-SEGNAM EQ  'E1BPE1MARART'.
          E1BPE1MARART = IDOC_DATA-SDATA.
          IF E1BPE1MARART-PR_REF_MAT_VERSION IS NOT INITIAL.

            MOVE E1BPE1MARART-PR_REF_MAT_VERSION TO VL_NEWVALUE.
            CALL FUNCTION 'ZCHANGE_ARTMAS_FIELDS_Z'
            EXPORTING
              I_TABLE             = 'MARA'
              I_STRUCTURE         = 'MARA'
              I_MATNR             = E1BPE1MARART-MATERIAL
              I_WERKS             = SPACE
              I_NEWVALUE          = VL_NEWVALUE
              I_CHANGEFIELD       = 'ZCVEPR'.

            UPDATE MARA SET ZCVEPR = E1BPE1MARART-PR_REF_MAT_VERSION
            WHERE MATNR EQ E1BPE1MARART-MATERIAL.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DATA: IT_MARA TYPE STANDARD TABLE OF MARA,
            WA_MARA TYPE MARA.

      IF CLIENTEXTX[] IS NOT INITIAL.
        SELECT *
        FROM MARA
        INTO TABLE IT_MARA
        FOR ALL ENTRIES IN CLIENTEXT
        WHERE MATNR EQ CLIENTEXT-MATERIAL.
        SORT IT_MARA BY MATNR.
      ENDIF.

      SORT CLIENTEXT BY MATERIAL.
      LOOP AT CLIENTEXTX.
        READ TABLE CLIENTEXT WITH KEY MATERIAL = CLIENTEXTX-MATERIAL BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          READ TABLE IT_MARA WITH KEY MATNR = CLIENTEXTX-MATERIAL INTO WA_MARA BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            IF CLIENTEXTX-FIELD1 EQ 'X'.

              MOVE CLIENTEXT-FIELD1 TO VL_NEWVALUE.
              CALL FUNCTION 'ZCHANGE_ARTMAS_FIELDS_Z'
              EXPORTING
                I_TABLE             = 'MARA'
                I_STRUCTURE         = 'MARA'
                I_MATNR             = WA_MARA-MATNR
                I_WERKS             = SPACE
                I_NEWVALUE          = VL_NEWVALUE
                I_CHANGEFIELD       = 'ZMULTJDA'.

              UPDATE MARA SET ZMULTJDA = CLIENTEXT-FIELD1
              WHERE MATNR EQ WA_MARA-MATNR.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      DATA: IT_MARC TYPE STANDARD TABLE OF MARC,
            WA_MARC TYPE MARC.

      IF PLANTEXT[] IS NOT INITIAL.
        SELECT *
        FROM MARC
        INTO TABLE IT_MARC
        FOR ALL ENTRIES IN PLANTEXT
        WHERE MATNR EQ PLANTEXT-MATERIAL AND
        WERKS EQ PLANTEXT-PLANT.
        SORT IT_MARC BY MATNR WERKS.
      ENDIF.

      SORT PLANTEXT BY MATERIAL PLANT.
      LOOP AT PLANTEXTX.
        READ TABLE PLANTEXT WITH KEY MATERIAL = PLANTEXTX-MATERIAL
        PLANT  = PLANTEXTX-PLANT BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          READ TABLE IT_MARC WITH KEY MATNR = PLANTEXTX-MATERIAL
          WERKS = PLANTEXTX-PLANT INTO WA_MARC BINARY SEARCH.
          IF SY-SUBRC EQ 0.
            IF PLANTEXTX-FIELD1 EQ 'X'.
              MOVE PLANTEXT-FIELD1 TO VL_NEWVALUE.
              CALL FUNCTION 'ZCHANGE_ARTMAS_FIELDS_Z'
              EXPORTING
                I_TABLE             = 'MARC'
                I_STRUCTURE         = 'DMARC'
                I_MATNR             = WA_MARC-MATNR
                I_WERKS             = WA_MARC-WERKS
                I_NEWVALUE          = VL_NEWVALUE
                I_CHANGEFIELD       = 'ZCHKJDA'.

              UPDATE MARC SET ZCHKJDA = PLANTEXT-FIELD1
              WHERE MATNR EQ WA_MARC-MATNR AND WERKS EQ WA_MARC-WERKS.
            ENDIF.
            IF PLANTEXTX-FIELD2 EQ 'X'.
              MOVE PLANTEXT-FIELD2 TO VL_NEWVALUE.
              CALL FUNCTION 'ZCHANGE_ARTMAS_FIELDS_Z'
              EXPORTING
                I_TABLE             = 'MARC'
                I_STRUCTURE         = 'DMARC'
                I_MATNR             = WA_MARC-MATNR
                I_WERKS             = WA_MARC-WERKS
                I_NEWVALUE          = VL_NEWVALUE
                I_CHANGEFIELD       = 'ZABASTO'.

              UPDATE MARC SET ZABASTO = PLANTEXT-FIELD2
              WHERE MATNR EQ WA_MARC-MATNR AND WERKS EQ WA_MARC-WERKS.
            ENDIF.

            IF PLANTEXTX-FIELD3 EQ 'X'.
              MOVE PLANTEXT-FIELD3 TO VL_NEWVALUE.
              CALL FUNCTION 'ZCHANGE_ARTMAS_FIELDS_Z'
              EXPORTING
                I_TABLE             = 'MARC'
                I_STRUCTURE         = 'DMARC'
                I_MATNR             = WA_MARC-MATNR
                I_WERKS             = WA_MARC-WERKS
                I_NEWVALUE          = VL_NEWVALUE
                I_CHANGEFIELD       = 'ZPLANOG'.

              UPDATE MARC SET ZPLANOG = PLANTEXT-FIELD3
              WHERE MATNR EQ WA_MARC-MATNR AND WERKS EQ WA_MARC-WERKS.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDLOOP.
endif.

ENDENHANCEMENT.
