 fprintf(fid_display, colorizestring('red', ' <br/>  <font size="+1"> ###################   THE END   ########################'));web(filename_display);
 fclose(fid_display);
 
WarnWave = [sin(1:.6:400), sin(1:.7:400), sin(1:.4:400)];
WarnWave=[WarnWave 1.3*WarnWave WarnWave];
Audio = audioplayer(WarnWave, 12050);
play(Audio);
