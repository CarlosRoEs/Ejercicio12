*&---------------------------------------------------------------------*
*&  Include           ZF20_CRE_EJER12_EVT
*&---------------------------------------------------------------------*

INITIALIZATION.

  CLEAR: gv_datos_ebeln,
         gv_datos_matnr,
         gv_datos_selec,
         gt_lifnr[],
         gt_pedido[],
         gt_matnr[],
         gt_material[],
         gt_selec[].

AT SELECTION-SCREEN.

  IF s_ebeln IS INITIAL AND p_matnr IS INITIAL.
    MESSAGE s002(zf20_cre_mensajes) DISPLAY LIKE rs_c_error. "Uno de los campos debe de estar rellenos.
  ELSEIF s_ebeln IS NOT INITIAL AND p_matnr IS NOT INITIAL.
    PERFORM comprobar_seleccion.
  ELSEIF s_ebeln IS NOT INITIAL.
    PERFORM comprobar_seleccion_pedido.
  ELSEIF p_matnr IS NOT INITIAL.
    PERFORM comprobar_seleccion_material.
  ENDIF.


START-OF-SELECTION.

  IF gv_datos_ebeln IS NOT INITIAL.
    PERFORM seleccionar_posiciones.
  ENDIF.

  IF gv_datos_matnr IS NOT INITIAL.
    PERFORM seleccionar_proveedor.
  ENDIF.

  IF gv_datos_selec IS NOT INITIAL.
    PERFORM seleccionar_datos.
  ENDIF.


END-OF-SELECTION.

  IF gv_datos_ebeln IS NOT INITIAL OR gv_datos_matnr IS NOT INITIAL OR gv_datos_selec IS NOT INITIAL.
    CALL SCREEN '9000'.
  ENDIF.