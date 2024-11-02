-- See below for example cleanup script from commercial Instant Win game LilLadyBingo.
  -- This should be updated to appropriately delete all GDS data for the target game (table name and conditions may differ).
  -- 
  -- DELETE FROM GDS_COM_IW_SCENARIO WHERE FAMILY_ID = '300-2011';
  -- COMMIT;
  --
  -- Delete below sql code after your changes.
  
  BEGIN
    RAISE_APPLICATION_ERROR(-20999, 'Invalid GDS cleanup script. Check src/paytables/demo/gds/gds_delete/*.sql files.');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  /