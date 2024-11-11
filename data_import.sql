create or replace procedure data_import (table_name in varchar2) is 

    v_file utl_file.file_type;
    v_line          varchar2(32767);
    v_sql           varchar2(4000);
    v_columns       VARCHAR2(32767);  
    v_values        VARCHAR2(32767);
    v_values2       varchar2(1000);                                                                                                                                                                                                   
    v_directory     VARCHAR2(30) := 'DATA_DIR';                                                                                          
    v_table_name    VARCHAR2(30) := table_name;

begin
                                                                                                                                                                                                                                                                       
    --open csv file for reading                                                                                                   
    v_file      := UTL_FILE.FOPEN(v_directory,v_table_name|| '.csv','R');

    --read first line to skip header                                                                                             
    UTL_FILE.GET_LINE(v_file,v_line);                                                                                            
    
    --call the create_table SP to create table
    create_table(v_table_name);

    -- read remaining data and insert into the table                                                                                
    loop                                                                                                                         
        begin 
            --preprocessing the data
            utl_file.get_line(v_file,v_line);                                                                             
            v_line      := replace(v_line,'''',''''''); --to change the data having the ' symbol to become ''                                                                                        
            v_line      := replace(v_line,'"','');      --to remove the " symbol at the beginning and end of each data                                                                                         
            v_values    := '';

            FOR i IN 1 .. REGEXP_COUNT(v_line, ',') + 1 LOOP                                                            
                -- Concatenate single quotes around each value, followed by a comma                                                   
                v_values := v_values || '''' || REGEXP_SUBSTR(v_line, '[^,]+', 1, i) || '''' || ',';                                   
            END LOOP;

            v_values    := rtrim(v_values,','); --remove trailing commas for last item                                                    
            v_sql       :='INSERT INTO '|| v_table_name || ' VALUES(' || v_values || ')';

            execute immediate v_sql;
                                                                                                                                                          
        exception
            when no_data_found then                
                exit;
            when others THEN
                dbms_output.put_line('error processing record: '|| sqlerrm);
                continue;                                                
        end;
    end loop;
                                                                                               
    utl_file.fclose(v_file);
    DBMS_OUTPUT.PUT_LINE('Data imported successfully into ' || v_table_name); 

exception
    when others then                           
        if utl_file.is_open(v_file) then             
            utl_file.fclose(v_file);             
        end if;
                                       
        dbms_output.put_line('Error: '|| SQLERRM);    
end;