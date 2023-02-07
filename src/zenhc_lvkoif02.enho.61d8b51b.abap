"Name: \PR:SAPLVKOI\FO:IDOC_IN_DATENBANK\SE:BEGIN\EI
ENHANCEMENT 0 ZENHC_LVKOIF02.
data: lv_unimed(6).
tables: maw1, mara, edid4.

data: it_edid4 like edid4 occurs 0 with header line.
data: wa_konp like e1konp occurs 0 with header line.
data: wa_komg like e1komg occurs 0 with header line.

select *
  into table it_edid4
    from edid4
  where docnum eq h_docnum
  and segnam =  'E1KOMG'.

read table it_edid4 with key segnam = 'E1KOMG'.

if sy-subrc eq 0.
  move it_edid4-sdata to wa_komg.
endif.


if wa_komg-kschl = 'VKP0'. " VALIDAR UNIDAD DE MEDIDA.

loop at  it_edid4 where segnam = 'E1KONP'.
  move it_edid4-sdata to wa_konp.
  clear: lv_unimed.
  if wa_konp-kschl = 'VKP0'. "En caso de que sea la plantilla de ventas, entra por aqui.
     select single * from maw1
      where matnr  = wa_komg-vakey_long+6(18)
      and wvrkm = wa_komg-vakey_long+24(2).
  endif.
endloop.

if maw1-wvrkm is not initial.
    move maw1-wvrkm to lv_unimed. "En caso de que la unidad de medida esté en la MAW1.
  else.
    select single * from mara
       where matnr  = wa_komg-vakey_long+6(18)
     and meins = wa_komg-vakey_long+24(2).

    if sy-subrc eq 0.           "En caso de que la unidad de medida esté en la MARA.
      move mara-meins to lv_unimed.
      else.
          clear: idoc_status-msgv2.
*          idoc_status-docnum = idoc_contrl-docnum.
          idoc_status-repid  = sy-repid.
          idoc_status-uname  = sy-uname.
          idoc_status-status = 51.
          idoc_status-msgty  = 'E'.
          idoc_status-msgid  = 'ZFI'.
          idoc_status-msgno  = '005'.                  "Fehler bei Commit
          idoc_status-msgv1  = wa_komg-vakey_long+24(2).
          idoc_status-msgv2  = subrc.
          append idoc_status.
          subrc = 1.
        exit.
    endif.
    endif.


elseif wa_komg-kschl = 'ZPB0'. " VALIDAR REG. INFO.


data: begin of pto_eina occurs 0.
        include structure eina.
data: end of pto_eina.

data: begin of pti_matnr occurs 0.
        include structure eina_matnr.
data: end of pti_matnr.

data: begin of pti_lifnr occurs 0.
        include structure eina_lifnr.
data: end of pti_lifnr.

move-corresponding wa_komg to pti_matnr.
append pti_matnr.

move-corresponding wa_komg to pti_lifnr.
append pti_lifnr.

call function 'ME_EINA_READ'
 exporting
   relif_only             = 'X'
   refresh_buffer         = 'X'
 tables
   pti_matnr              = pti_matnr
   pti_lifnr              = pti_lifnr
   pto_eina               = pto_eina
 exceptions
   no_records_found       = 1
   others                 = 2.


if sy-subrc ne 0.           "En caso de que el material no tenga reginfo
         clear: idoc_status-msgv2.
*          idoc_status-docnum = idoc_contrl-docnum.
          idoc_status-repid  = sy-repid.
          idoc_status-uname  = sy-uname.
          idoc_status-status = 51.
          idoc_status-msgty  = 'E'.
          idoc_status-msgid  = 'ZFI'.
          idoc_status-msgno  = '042'.                  "Fehler bei Commit
          idoc_status-msgv1  = pti_matnr-matnr.
          idoc_status-msgv2  = pti_lifnr-lifnr.
          append idoc_status.
          subrc = 1.
        exit.
    endif.

endif.
ENDENHANCEMENT.
