*&---------------------------------------------------------------------*
*& Report ZML_IMAGE_CLASSIF
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zml_image_classif.

PARAMETERS: p_fname TYPE rlgrap-filename.


TYPES: BEGIN OF ty_filetab,
         value TYPE x,
       END OF ty_filetab.

DATA: lv_url            TYPE string,
      lt_filetable      TYPE filetable,
      lv_rc             TYPE i,
      lv_file_name      TYPE string,
      lt_file           TYPE STANDARD TABLE OF ty_filetab,
      lv_file_content   TYPE xstring,
      lv_file_form_data TYPE string.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.



  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Choose a file'
    CHANGING
      file_table   = lt_filetable
      rc           = lv_rc.

  lv_file_name = lt_filetable[ 1 ]-filename.
  p_fname = lv_file_name.

AT SELECTION-SCREEN.


*Covert file to binary format
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename   = lv_file_name
      filetype   = 'BIN'
    IMPORTING
      filelength = DATA(lv_input_len)
    CHANGING
      data_tab   = lt_file.


*convert file to XSTRING
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_input_len
    IMPORTING
      buffer       = lv_file_content
    TABLES
      binary_tab   = lt_file.

************************Initailize HTTP resquest creation************************************

  lv_url = 'https://sandbox.api.sap.com/ml/imageclassifier/inference_sync'.


  cl_http_client=>create_by_url( EXPORTING url = lv_url
                                 IMPORTING client = DATA(lo_http_client) ).

  lo_http_client->propertytype_logon_popup = if_http_client=>co_disabled.

  lo_http_client->request->set_method( if_http_request=>co_request_method_post ).


***********************************Request Headers*********************************************

* get data in JSON format
  lo_http_client->request->set_header_field( name = 'Accept'
                                   value = 'application/json' ).

* Set API key for image classification API
  lo_http_client->request->set_header_field( name = 'APIKey'
                                 value = 'Your Own API Key' ).

  DATA(lo_rest_client) = NEW cl_rest_http_client( lo_http_client ).

  DATA(lo_request) = lo_rest_client->if_rest_client~create_request_entity( ).

  lo_request->set_content_type( if_rest_media_type=>gc_multipart_form_data ).

  DATA(lo_post_file) = NEW cl_rest_multipart_form_data( lo_request ).

* send Image file to API
  lo_post_file->set_file( iv_name = 'files'  "This is the name of fied which API expects: See API documentation
                          iv_filename = lv_file_name
                          iv_type = 'image/jpeg'
                          iv_data = lv_file_content ).

  lo_post_file->if_rest_entity_provider~write_to( lo_request ).

  lo_rest_client->if_rest_resource~post( lo_request ).

*******************get Response******************************************
  DATA(lo_response) = lo_rest_client->if_rest_client~get_response_entity( ).

  DATA(lv_response) = lo_response->get_string_data( ).

  cl_demo_output=>display( lv_response ).