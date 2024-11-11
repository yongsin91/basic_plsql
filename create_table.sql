create or replace procedure create_table(table_name in varchar2) is 

    v_file          utl_file.file_type;
    v_header        varchar2(32767);
    v_first_row     varchar2(32767);
    v_sql           varchar2(32767);
    v_columns       VARCHAR2(1000);
    v_data          varchar2(1000);                                                                                                   
    v_directory     VARCHAR2(30) := 'DATA_DIR';                                                                                          
    v_table_name    VARCHAR2(30) := table_name;

begin
                                                                                                                                                                                                                                                                       
    --open csv file for reading                                                                                                   
    v_file      := UTL_FILE.FOPEN(v_directory,v_table_name|| '.csv','R');

    --read first line and get v_header                                                                                             
    UTL_FILE.GET_LINE(v_file,v_header); 
    UTL_FILE.GET_LINE(v_file,v_first_row);  

    v_header    := replace(v_header,'"','');
    v_first_row := replace(v_first_row,'"','');
    v_first_row := replace(v_first_row,'''','''''');

    -- Start constructing the CREATE TABLE statement
    v_sql := 'CREATE TABLE ' || v_table_name || ' (';                                                                                         

    -- Parse the header and first row to determine column names and data types
    FOR i IN 1 .. REGEXP_COUNT(v_header, ',') + 1 LOOP
        
        -- Get column name from header
        v_columns := REGEXP_SUBSTR(v_header, '[^,]+', 1, i);
        v_data := REGEXP_SUBSTR(v_first_row, '[^,]+', 1, i);

         -- Infer the data type from the first row's values
        IF regexp_like(v_data,'[A-Za-z]') THEN
            v_sql := v_sql || v_columns || ' VARCHAR2(1000), ';
        ELSE
            v_sql := v_sql || v_columns || ' NUMBER, ';
        END IF;

    END LOOP;

    -- Remove the last comma and add closing parenthesis
    v_sql := RTRIM(v_sql, ', ') || ')';
        
    execute immediate v_sql;
                                                                                              
    utl_file.fclose(v_file);
    DBMS_OUTPUT.PUT_LINE('Table created successfully - ' || v_table_name); 

exception
    when others then                           
        if utl_file.is_open(v_file) then             
            utl_file.fclose(v_file);             
        end if;
                                       
        dbms_output.put_line('Error: '|| SQLERRM);    
end;