*&---------------------------------------------------------------------*
*&  Include           ZF20_CRE_EJER12_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  COMPROBAR_SELECCION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM comprobar_seleccion_pedido.

    SELECT ebeln lifnr
      FROM ekko
      INTO TABLE gt_lifnr
      WHERE ebeln IN s_ebeln.
  
    IF gt_lifnr[] IS INITIAL.
      MESSAGE s003(zf20_cre_mensajes) DISPLAY LIKE rs_c_error. "No hay proveedor para el/los pedido/s seleccionado/s.
    ELSE.
      gv_datos_ebeln = abap_true.
    ENDIF.
  ENDFORM.                    " COMPROBAR_SELECCION
*&---------------------------------------------------------------------*
*&      Form  SELECCIONAR_POSICIONES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM seleccionar_posiciones .
  
    DATA: lt_lifnr_aux TYPE STANDARD TABLE OF ty_lifnr.
  
    CLEAR: lt_lifnr_aux[].
*  Para no borrar los datos de la tabla gt_lifnr me creo una auxiliar.
    lt_lifnr_aux[] = gt_lifnr[].
  
    IF lt_lifnr_aux[] IS NOT INITIAL.
*    Ordeno y borro los datos de la tabla auxiliar.
      SORT lt_lifnr_aux BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_lifnr_aux COMPARING ebeln.
  
      IF lt_lifnr_aux[] IS NOT INITIAL.
  
*      Se realiza la selección de campos.
        SELECT ebeln
               ebelp
               matnr
               bukrs
               werks
               menge
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE gt_pedido
          FOR ALL ENTRIES IN lt_lifnr_aux
          WHERE ebeln EQ lt_lifnr_aux-ebeln.
  
        IF gt_pedido[] IS NOT INITIAL.
*        Se introduce el campo lifnr(proveedor) en la tabla de salida.
          LOOP AT gt_pedido ASSIGNING FIELD-SYMBOL(<fs_pedido>).
            READ TABLE lt_lifnr_aux ASSIGNING FIELD-SYMBOL(<fs_lifnr_aux>) WITH KEY ebeln = <fs_pedido>-ebeln.
            IF sy-subrc EQ 0.
              <fs_pedido>-lifnr = <fs_lifnr_aux>-lifnr.
            ENDIF.
          ENDLOOP.
        ELSE.
          gv_datos_ebeln = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.                    " SELECCIONAR_POSICIONES
*&---------------------------------------------------------------------*
*&      Form  CREAR_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM crear_container .
  
*** Si el contenedor no esta creado se crea.
    IF go_container IS INITIAL.
  
      CREATE OBJECT go_container
        EXPORTING
          container_name              = gc_container
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE cl_esh_adm_constants=>gc_msgty_s
                            NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                            DISPLAY LIKE cl_esh_adm_constants=>gc_msgty_e.
      ENDIF.
  
      PERFORM crear_fieldcat.
    ENDIF.
  ENDFORM.                    " CREAR_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  CREAR_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM crear_fieldcat .
  
    CONSTANTS: lc_structure_pedido   TYPE dd02l-tabname VALUE 'ZF20_CRE_EJER12_PEDIDO',
               lc_structure_material TYPE dd02l-tabname VALUE 'ZF20_CRE_EJER12_MATERIAL',
               lc_matnr(5)           TYPE c             VALUE 'MATNR'.
  
*** Dependiendo de si la variable a la que pertenece se encuentre iniciada
*** se seleccionara una estructura u otra.
    DATA(lc_structure) = COND dd02l-tabname( WHEN gv_datos_ebeln IS NOT INITIAL
                                              THEN lc_structure_pedido
                                              WHEN gv_datos_matnr IS NOT INITIAL OR gv_datos_selec IS NOT INITIAL
                                              THEN lc_structure_material ).
  
*** Se crea el catalogo dinámicamente dependiendo del resultado de la condición.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = lc_structure
      CHANGING
        ct_fieldcat            = gt_fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc NE 0.
      RAISE inconsistent_interface.
      RAISE program_error.
    ENDIF.
  
*** Si la estructura es igual a ZF20_CRE_EJER12_MATERIAL entra en el loop para
*** asignar el evento.
    IF lc_structure EQ lc_structure_material. "ZF20_CRE_EJER12_MATERIAL
      LOOP AT gt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
        CASE <fs_fieldcat>-fieldname.
          WHEN lc_matnr.
            <fs_fieldcat>-hotspot = abap_true.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  
*&---------------------------------------------------------------------*
*&  Configuración y formato del layout.
*&---------------------------------------------------------------------*
  gs_layout-zebra = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode = 'A'.

*&---------------------------------------------------------------------*
*&  Graba las variantes del layout.
*&---------------------------------------------------------------------*
    gv_variant-report = sy-repid.
    gv_variant-username = sy-uname.
  
  ENDFORM.                    " CREAR_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_9000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM user_command_9000 .
  
    CASE sy-ucomm.
      WHEN gc_back.
        LEAVE TO SCREEN 0.
      WHEN gc_exit.
        LEAVE PROGRAM.
      WHEN gc_cancel.
        LEAVE SCREEN.
      WHEN OTHERS.
    ENDCASE.
  ENDFORM.                    " USER_COMMAND_9000
*&---------------------------------------------------------------------*
*&      Form  CREAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM crear_alv .
  
*** Se crea un field symbol para que la selección de la tabla de salida sea dinámica.
    FIELD-SYMBOLS: <fs_table> TYPE ANY TABLE.
  
    IF go_alv_grid IS INITIAL.
  
*** Se asigna el field symbol a las tablas de salida.
      IF gv_datos_ebeln IS NOT INITIAL.
        ASSIGN gt_pedido TO <fs_table>.
      ELSEIF gv_datos_matnr IS NOT INITIAL OR gv_datos_selec IS NOT INITIAL.
        ASSIGN gt_material TO <fs_table>.
      ENDIF.
  
      CREATE OBJECT go_alv_grid
        EXPORTING
          i_parent          = go_container
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          OTHERS            = 5.
      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
  
*** Se crea el objeto para que nos lleve a la transacción MM03 Visualización Material.
      CREATE OBJECT go_hotspot .
      SET HANDLER go_hotspot->handle_hotspot_click FOR go_alv_grid.
  
*    Se muestra el alv.
    go_alv_grid->set_table_for_first_display(
        EXPORTING
*          i_buffer_active               =
*          i_bypassing_buffer            =
*          i_consistency_check           =
*          i_structure_name              =
          is_variant                    = gv_variant
          i_save                        = 'A'
          i_default                     = 'X'
          is_layout                     = gs_layout
*          is_print                      =
*          it_special_groups             =
*          it_toolbar_excluding          =
*          it_hyperlink                  =
*          it_alv_graphics               =
*          it_except_qinfo               =
*          ir_salv_adapter               =
        CHANGING
          it_outtab                     = <fs_table>
          it_fieldcatalog               = gt_fieldcat
*          it_sort                       =
*          it_filter                     =
          EXCEPTIONS
            invalid_parameter_combination = 1
            program_error                 = 2
            too_many_lines                = 3
            OTHERS                        = 4 ).
  
      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDFORM.                    " CREAR_ALV
*&---------------------------------------------------------------------*
*&      Form  COMPROBAR_SELECCION_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM comprobar_seleccion_material .
  
    SELECT ebeln ebelp matnr werks menge
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_matnr
      WHERE matnr = p_matnr.
  
    IF gt_matnr[] IS INITIAL.
      MESSAGE s004(zf20_cre_mensajes) DISPLAY LIKE rs_c_error. "No existe el material introducido.
    ELSE.
      gv_datos_matnr = abap_true.
  
    ENDIF.
  ENDFORM.                    " COMPROBAR_SELECCION_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  SELECCIONAR_PROVEEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM seleccionar_proveedor .
  
    CONSTANTS: lc_memory_id(2) TYPE c VALUE 'TI'.
  
    DATA: lt_matnr_aux TYPE STANDARD TABLE OF ty_matnr.
  
    CLEAR: lt_matnr_aux[].
  
    lt_matnr_aux[] = gt_matnr[].
  
    IF lt_matnr_aux[] IS NOT INITIAL.
      SORT lt_matnr_aux BY ebeln ebelp.
      DELETE ADJACENT DUPLICATES FROM lt_matnr_aux COMPARING ebeln ebelp.
  
      IF lt_matnr_aux[] IS NOT INITIAL.
***   Se vuelve a limpiar la tabla debido a que se reutiliza.
        CLEAR: gt_material[].
        SELECT ebeln bukrs lifnr
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE gt_material
          FOR ALL ENTRIES IN lt_matnr_aux
          WHERE ebeln EQ lt_matnr_aux-ebeln.
  
        IF gt_material[] IS NOT INITIAL.
  
***     Se introducen los campos posición, material, centro y cantidad en la tabla de salida.
          LOOP AT gt_material ASSIGNING FIELD-SYMBOL(<fs_material>).
            READ TABLE lt_matnr_aux ASSIGNING FIELD-SYMBOL(<fs_matnr_aux>) WITH KEY ebeln = <fs_material>-ebeln.
            IF sy-subrc EQ 0.
  
              <fs_material>-ebelp = <fs_matnr_aux>-ebelp.
              <fs_material>-matnr = <fs_matnr_aux>-matnr.
              <fs_material>-werks = <fs_matnr_aux>-werks.
              <fs_material>-menge = <fs_matnr_aux>-menge.
***         Según la condición se introduce un valor u otro para mostrar el icono.
              <fs_material>-icono = COND #( WHEN <fs_material>-menge LT 100
                                              THEN icon_led_green
                                            WHEN <fs_material>-menge BETWEEN 100 AND 1000
                                              THEN icon_led_red
                                            WHEN <fs_material>-menge GT 1000
                                              THEN icon_led_yellow ).
            ENDIF.
          ENDLOOP.
          EXPORT gt_material TO MEMORY ID lc_memory_id.
          UNASSIGN <fs_material>.
        ELSE.
          gv_datos_matnr = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.                    " SELECCIONAR_PROVEEDOR
  
*&---------------------------------------------------------------------*
*&      Form  COMPROBAR_SELECCION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM comprobar_seleccion .
  
    SELECT ebeln ebelp matnr werks menge
      FROM ekpo
      INTO CORRESPONDING FIELDS OF TABLE gt_selec
      WHERE ebeln IN s_ebeln
      AND matnr EQ p_matnr.
  
    IF gt_selec[] IS INITIAL.
      MESSAGE s005(zf20_cre_mensajes) DISPLAY LIKE rs_c_error. "No existen datos para los valores introducidos.
    ELSE.
      gv_datos_selec = abap_true.
  
    ENDIF.
  ENDFORM.                    " COMPROBAR_SELECCION
*&---------------------------------------------------------------------*
*&      Form  SELECCIONAR_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
  FORM seleccionar_datos .
  
    CONSTANTS: lc_memory_id(2) TYPE c VALUE 'TI'.
  
    DATA: lt_selec_aux TYPE STANDARD TABLE OF ty_matnr.
  
    CLEAR: lt_selec_aux[].
  
    lt_selec_aux[] = gt_selec[].
  
    IF lt_selec_aux[] IS NOT INITIAL.
  
      SORT lt_selec_aux BY ebeln ebelp.
      DELETE ADJACENT DUPLICATES FROM lt_selec_aux COMPARING ebeln ebelp.
  
      IF lt_selec_aux[] IS NOT INITIAL.
        CLEAR: gt_material[].
        SELECT ebeln bukrs lifnr
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE gt_material
          FOR ALL ENTRIES IN lt_selec_aux
          WHERE ebeln EQ lt_selec_aux-ebeln.
  
        IF gt_material[] IS NOT INITIAL.
  
***     Se introducen los campos posición, material, centro y cantidad en la tabla de salida.
          LOOP AT gt_material ASSIGNING FIELD-SYMBOL(<fs_material>).
            READ TABLE lt_selec_aux ASSIGNING FIELD-SYMBOL(<fs_selec_aux>) WITH KEY ebeln = <fs_material>-ebeln.
            IF sy-subrc EQ 0.
  
              <fs_material>-ebelp = <fs_selec_aux>-ebelp.
              <fs_material>-matnr = <fs_selec_aux>-matnr.
              <fs_material>-werks = <fs_selec_aux>-werks.
              <fs_material>-menge = <fs_selec_aux>-menge.
***         Según la condición se introduce un valor u otro para mostrar el icono.
              <fs_material>-icono = COND #( WHEN <fs_selec_aux>-menge LT 100
                                              THEN icon_led_green
                                            WHEN <fs_selec_aux>-menge BETWEEN 100 AND 1000
                                              THEN icon_led_red
                                            WHEN <fs_selec_aux>-menge GT 1000
                                              THEN icon_led_yellow ).
            ENDIF.
          ENDLOOP.
          EXPORT gt_material TO MEMORY ID lc_memory_id.
          UNASSIGN <fs_material>.
        ELSE.
          gv_datos_selec = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDFORM.                    " SELECCIONAR_DATOS