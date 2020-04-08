*&---------------------------------------------------------------------*
*&  Include           ZF20_CRE_EJER12_SEL
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Pantallas de Seleción.
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. "Pantalla de selección.

SELECT-OPTIONS: s_ebeln FOR ekko-ebeln. "Número de pedido

SELECTION-SCREEN SKIP.

PARAMETERS: p_matnr TYPE matnr. "Material

SELECTION-SCREEN END OF BLOCK b1.