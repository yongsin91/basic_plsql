create or replace procedure olist_geo_cleaning is 

    v_count NUMBER;

BEGIN
    -- TO REPLACE ALL CITY NAME TO BE THE SAME AS PER THE ZIP CODE
    -- TO CHECK MOST OCCURING NAME IN EACH ZIP CODE, OTHER VARIATIONS ARE CONSIDERED AS TYPO
    FOR rec IN (
        SELECT      ZIP_CODE, CITY
        FROM (
            SELECT      GEOLOCATION_ZIP_CODE_PREFIX ZIP_CODE, 
                        GEOLOCATION_CITY CITY, 
                        ROW_NUMBER() OVER ( PARTITION BY GEOLOCATION_ZIP_CODE_PREFIX ORDER BY COUNT(*) DESC) as RN
            FROM        OLIST_GEOLOCATION_DATASET
            GROUP BY    GEOLOCATION_ZIP_CODE_PREFIX, GEOLOCATION_CITY)
        WHERE RN = 1
    )

    --TO UPDATE THE DATASET AND STANDARDIZE ALL THE CITY NAMES
    LOOP 
        -- update the city name 
        UPDATE  OLIST_GEOLOCATION_DATASET
        set     GEOLOCATION_CITY = rec.CITY
        where   GEOLOCATION_ZIP_CODE_PREFIX = rec.ZIP_CODE; 
    END LOOP;

    COMMIT;

    -- Optionally, log the success
    DBMS_OUTPUT.PUT_LINE('All city names updated for each zip code.');


    -- COUNT DUPLICATES
    SELECT COUNT(*) INTO v_count
    FROM (  SELECT  ROWID AS RID,
                    ROW_NUMBER() OVER ( PARTITION BY GEOLOCATION_LAT, GEOLOCATION_LNG
                                        ORDER BY ROWID ) AS RN
            FROM    OLIST_GEOLOCATION_DATASET )
        WHERE RN>1 ;

    -- TO REMOVE ALL DUPLICATE DATA
    DELETE FROM OLIST_GEOLOCATION_DATASET geo
    WHERE geo.ROWID IN (
        SELECT RID
        FROM (
            SELECT  ROWID AS RID,
                    ROW_NUMBER() OVER ( PARTITION BY GEOLOCATION_LAT, GEOLOCATION_LNG
                                        ORDER BY ROWID ) AS RN
            FROM    OLIST_GEOLOCATION_DATASET )
        WHERE RN>1  );
    
    COMMIT;

    -- Optionally, log the success
    DBMS_OUTPUT.PUT_LINE('All duplicates city names and coordinates removed.');
    DBMS_OUTPUT.PUT_LINE('Number of duplicates removed: '||v_count);

EXCEPTION
   WHEN OTHERS THEN
       -- Handle any errors that occur during execution
       DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
       ROLLBACK; -- Roll back the transaction if an error occurs
END;
