"Name: \PR:SAPMWAKA\FO:TOP_BUILD_XCALP_VB_FROM_XWALED\SE:END\EI
ENHANCEMENT 0 ZENH_MODIFY_WALE_VKGEN.

    READ TABLE G_T_XWALED INDEX 1.

    IF G_T_XWALED-VKDAB LT SY-DATUM.
      LOOP AT G_T_XWALED.
        IF G_T_XWALED-VKGEN = B        " KONDITION ANGELEGT
        OR G_T_XWALED-VKGEN = E.       " AUF WERKSEBENE GEÄNDERT
          G_T_XWALED-VKKPS = F.      " STATUS VK-PREIS
          G_T_XWALED-VKGEN = F.      " STATUS VK-PREIS
          MODIFY G_T_XWALED.
        ENDIF.
      ENDLOOP.
    ENDIF.
ENDENHANCEMENT.