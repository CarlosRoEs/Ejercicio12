*&---------------------------------------------------------------------*
*&  Include           ZF20_CRE_EJER12_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'STATUS_9000'. "Hay que crear el status.
  SET TITLEBAR 'TITLE_9000'. "Hay que crear el title_bar.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MOSTRAR_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE mostrar_alv OUTPUT.

  PERFORM crear_container.

  PERFORM crear_alv.

ENDMODULE.                 " MOSTRAR_ALV  OUTPUT