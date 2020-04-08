*&---------------------------------------------------------------------*
*&  Include           ZF20_CRE_EJER12_CLS
*&---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.

    PUBLIC SECTION.
      DATA: gt_material TYPE STANDARD TABLE OF zf20_cre_ejer12_material,
            gt_bdcdata  TYPE STANDARD TABLE OF bdcdata.
  
      DATA: gs_bdcdata LIKE LINE OF gt_bdcdata.
  
      METHODS:
        handle_hotspot_click
          FOR EVENT hotspot_click OF cl_gui_alv_grid
          IMPORTING e_row_id e_column_id,
  
        bdcdata_dynpro IMPORTING p_program TYPE bdc_prog
                                 p_dynpro TYPE bdc_dynr
                                 p_indicador TYPE bdc_start,
  
        bdcdata_field_matnr  IMPORTING p_name TYPE fnam_____4
                                       p_valor TYPE matnr,
  
        bdcdata_field_ok IMPORTING p_name TYPE fnam_____4
                                   p_valor TYPE fnam_____4,
  
        bdcdata_field_msichtausw IMPORTING p_name TYPE fnam_____4
                                           p_valor TYPE bdc_fval.
  
  ENDCLASS.
  
  CLASS lcl_event_handler IMPLEMENTATION.
  
    METHOD handle_hotspot_click.
  
      CONSTANTS: lc_mat(3)   TYPE c VALUE 'MAT',
                 lc_matnr(5) TYPE c VALUE 'MATNR',
                 lc_mm03(4)  TYPE c VALUE 'MM03', " Visualizar material.
                 lc_program TYPE bdc_prog VALUE 'SAPLMGMM',
                 lc_dynpro_0060 TYPE bdc_dynr VALUE 0060,
                 lc_dynpro_0070 TYPE bdc_dynr VALUE 0070,
                 lc_indicador TYPE bdc_start VALUE abap_true,
                 lc_rmmg1_matnr TYPE fnam_____4 VALUE 'RMMG1-MATNR',
                 lc_bdc_okcode TYPE fnam_____4 VALUE 'BDC_OKCODE',
                 lc_okcode TYPE fnam_____4 VALUE '=ENTR',
                 lc_msichtausw_kzsel_01 TYPE fnam_____4 VALUE 'MSICHTAUSW-KZSEL(01)',
                 lc_msichtausw_kzsel TYPE bdc_fval VALUE 'X',
                 lc_dismode TYPE ctu_mode VALUE 'E'.
  
*** Declaración de estructuras.
      DATA ls_opt TYPE ctu_params.
  
      IMPORT gt_material TO gt_material FROM MEMORY ID 'TI'.
      IF gt_material IS NOT INITIAL.
        READ TABLE gt_material ASSIGNING FIELD-SYMBOL(<fs_material>) INDEX e_row_id .
        IF sy-subrc EQ 0.
          CASE e_column_id-fieldname.
            WHEN lc_matnr.
              me->bdcdata_dynpro(
                EXPORTING
                  p_program   = lc_program
                  p_dynpro    = lc_dynpro_0060
                  p_indicador = lc_indicador ).
              me->bdcdata_field_matnr(
                EXPORTING
                  p_name  = lc_rmmg1_matnr
                  p_valor = <fs_material>-matnr ).
              me->bdcdata_field_ok(
                EXPORTING
                  p_name  = lc_bdc_okcode
                  p_valor = lc_okcode ).
              me->bdcdata_dynpro(
                EXPORTING
                  p_program   = lc_program
                  p_dynpro    = lc_dynpro_0070
                  p_indicador = lc_indicador ).
              me->bdcdata_field_msichtausw(
                EXPORTING
                  p_name  = lc_msichtausw_kzsel_01
                  p_valor = lc_msichtausw_kzsel ).
              me->bdcdata_field_ok(
                EXPORTING
                  p_name  = lc_bdc_okcode
                  p_valor = lc_okcode ).
  
              ls_opt-defsize = rs_c_true. "Tamaño Standar de la dynpro
              ls_opt-dismode = lc_dismode. "Visualizar errores.
  
              CALL TRANSACTION lc_mm03 USING gt_bdcdata
                                       OPTIONS FROM ls_opt.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDMETHOD.
  
    METHOD bdcdata_dynpro.
  
      CLEAR gs_bdcdata.
      gs_bdcdata-program = p_program.
      gs_bdcdata-dynpro = p_dynpro.
      gs_bdcdata-dynbegin = p_indicador.
      APPEND gs_bdcdata TO gt_bdcdata.
  
    ENDMETHOD.
  
    METHOD bdcdata_field_matnr.
  
      CLEAR: gs_bdcdata.
      gs_bdcdata-fnam = p_name.
      gs_bdcdata-fval = p_valor.
      APPEND gs_bdcdata TO gt_bdcdata.
  
    ENDMETHOD.
  
    METHOD bdcdata_field_ok.
  
      CLEAR: gs_bdcdata.
      gs_bdcdata-fnam = p_name.
      gs_bdcdata-fval = p_valor.
      APPEND gs_bdcdata TO gt_bdcdata.
  
    ENDMETHOD.
  
    METHOD bdcdata_field_msichtausw.
  
      CLEAR: gs_bdcdata.
      gs_bdcdata-fnam = p_name.
      gs_bdcdata-fval = p_valor.
      APPEND gs_bdcdata TO gt_bdcdata.
  
    ENDMETHOD.
  
  
  
  
  
  
  
  
  
  
  
  
  
  ENDCLASS.