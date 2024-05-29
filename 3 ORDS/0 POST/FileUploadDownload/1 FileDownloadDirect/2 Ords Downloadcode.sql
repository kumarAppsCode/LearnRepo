 
BEGIN
  ORDS.DEFINE_MODULE(
      p_module_name    => 'ora_image',
      p_base_path      => '/ora_image/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);
 
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id/contentPLSQL',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id/contentPLSQL',
      p_method         => 'GET',
      p_source_type    => 'resource/lob',
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select content_type, get_media(:id)
from media
where id = :id');
 
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id/contentPUREPLSQL',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id/contentPUREPLSQL',
      p_method         => 'GET',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'BEGIN
  DOWNLOAD_FILE(MEDIA_ID => :id);
END;');
 
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select ID ,
FILE_NAME ,
CONTENT_TYPE,
''./'' || id "$record" -- the $ tells ORDS to render this as a LINK
from media
order by id asc -- optional if you want insertion order');
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page => 0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'declare 
 image_id integer; 
 
begin
 
 insert into media (file_name,content_type,content) 
             values  (:file_name,:file_type,:body) -- :body is defined by ORDS
             returning id into image_id;
 :status := 201; -- http status code
 :location := ''./'' || image_id; -- included in the response to access the new record
 
end;');
 
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ora_image',
      p_pattern            => 'media/',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);
 
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ora_image',
      p_pattern            => 'media/',
      p_method             => 'POST',
      p_name               => 'file_name',
      p_bind_variable_name => 'file_name',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
 
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ora_image',
      p_pattern            => 'media/',
      p_method             => 'POST',
      p_name               => 'file_type',
      p_bind_variable_name => 'file_type',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
 
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'ora_image',
      p_pattern            => 'media/',
      p_method             => 'POST',
      p_name               => 'location',
      p_bind_variable_name => 'location',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);
 
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id',
      p_method         => 'GET',
      p_source_type    => 'json/item',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select FILE_NAME,
      CONTENT_TYPE,
      ID || ''/content'' "$file"
 from MEDIA
where ID = :id');
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id',
      p_method         => 'DELETE',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'delete from media
where id = :id');
 
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id/content',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
 
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'ora_image',
      p_pattern        => 'media/:id/content',
      p_method         => 'GET',
      p_source_type    => 'resource/lob',
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select CONTENT_TYPE, 
       CONTENT
  from MEDIA
 where ID = :id');
 
 
 
COMMIT;
END;
