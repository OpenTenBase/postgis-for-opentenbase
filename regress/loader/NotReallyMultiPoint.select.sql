select count(1) from (select ST_AsText(ST_SnapToGrid(the_geom,0.00001), 5) from loadedshp);

