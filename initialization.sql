
GRANT CREATE TABLE to yongsin;
GRANT EXECUTE ANY PROCEDURE TO yongsin;
GRANT READ, WRITE ON DIRECTORY data_dir TO yongsin;
GRANT INSERT ANY TABLE, UPDATE ANY TABLE, SELECT ANY TABLE, DELETE ANY TABLE, DROP ANY TABLE to yongsin;
BEGIN
  ORDS.ENABLE_SCHEMA(
    p_enabled => TRUE,
    p_schema  => 'yongsin',
    p_url_mapping_type => 'BASE_PATH',
    p_auto_rest_auth => FALSE
  );
END