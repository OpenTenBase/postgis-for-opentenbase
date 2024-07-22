select count(1) from (select ST_AsText(ST_SnapToGrid(the_geom,0.00000001), 8) from loadedshp);

