
--
CREATE OR REPLACE PROCEDURE download_file
(
    media_id NUMBER
)
AS
    vMIMETYPE VARCHAR2(256);
    vLENGTH NUMBER;
    vFILENAME VARCHAR2(2000);
    vBLOB BLOB;
BEGIN
    SELECT file_name, content_type, content INTO vFILENAME, vMIMETYPE, VBLOB
				FROM XXQIA_MEDIA
				WHERE id = media_id;
 
    vLENGTH := DBMS_LOB.GETLENGTH(vBLOB);
    owa_util.mime_header(NVL(vMIMETYPE, 'application/octet'), FALSE);
    htp.p('Content-length: ' || vLENGTH);
    htp.p('Content-Disposition: attachment; filename=' || SUBSTR(vFILENAME, INSTR(vFILENAME, '/') + 1) || '');
    owa_util.http_header_close;
    wpg_docload.download_file(vBLOB);
END download_file;
/
