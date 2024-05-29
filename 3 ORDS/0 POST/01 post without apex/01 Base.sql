DECLARE
BEGIN
  xxshoes_uniform_pkg.xxshoes_uniform_import_file(
     p_data => :body
     ,x_status => :x_status
     ,x_batch_id => :x_batch_id
  );
END;

--BEGIN
--XXQIA_COMPEN_STATEMENT_UPLOAD_PRO(:p_login,:p_year,:p_file_name,:p_remarks,p_data => :body);
--END;
