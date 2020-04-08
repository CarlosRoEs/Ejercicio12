*&---------------------------------------------------------------------*
*&  Include           ZF20_CRE_EJER12_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Declaración tablas.
*&---------------------------------------------------------------------*

TABLES: ekko.

*&---------------------------------------------------------------------*
*&  Declaración de tipos.
*&---------------------------------------------------------------------*

***EKKO. Cabecera del documento de compras
***EKPO. Posición del documento de compras

TYPES: BEGIN OF ty_lifnr,
          ebeln TYPE ekko-ebeln,
          lifnr TYPE ekko-lifnr,
       END OF ty_lifnr.

TYPES: BEGIN OF ty_matnr,
          ebeln TYPE ekpo-ebeln,
          ebelp TYPE ekpo-ebelp,
          matnr TYPE ekpo-matnr,
          werks TYPE ekpo-werks,
          menge type ekpo-menge,
       END OF ty_matnr.

*&---------------------------------------------------------------------*
*&  Declaración de tablas internas.
*&---------------------------------------------------------------------*
DATA: gt_lifnr    TYPE STANDARD TABLE OF ty_lifnr,
      gt_matnr    TYPE STANDARD TABLE OF ty_matnr,
      gt_selec    TYPE STANDARD TABLE OF ty_matnr,
      gt_pedido   TYPE STANDARD TABLE OF zf20_cre_ejer12_pedido,
      gt_material TYPE STANDARD TABLE OF zf20_cre_ejer12_material,
      gt_fieldcat TYPE lvc_t_fcat.

*&---------------------------------------------------------------------*
*&  Declaración de estructuras.
*&---------------------------------------------------------------------*
DATA: gs_layout   TYPE lvc_s_layo,
      gs_fieldcat TYPE lvc_s_fcat,
      gs_pedido   LIKE LINE OF gt_pedido.

*&---------------------------------------------------------------------*
*&  Declaración objetos.
*&---------------------------------------------------------------------*
DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_alv_grid  TYPE REF TO cl_gui_alv_grid,
      go_hotspot   TYPE REF TO lcl_event_handler.


*&---------------------------------------------------------------------*
*&  Declaración de constantes.
*&---------------------------------------------------------------------*
CONSTANTS: gc_container(10) TYPE c VALUE 'CCONTAINER',
           gc_back TYPE sy-ucomm VALUE 'BACK',
           gc_exit TYPE sy-ucomm VALUE 'EXIT',
           gc_cancel TYPE sy-ucomm VALUE 'CANCEL',
           gc_save TYPE sy-ucomm VALUE 'SAVE'.
*&---------------------------------------------------------------------*
*&  Declaración de variables.
*&---------------------------------------------------------------------*

DATA: gv_datos_matnr TYPE flag,
      gv_datos_ebeln TYPE flag,
      gv_datos_selec TYPE flag,
      gv_variant     TYPE disvariant.