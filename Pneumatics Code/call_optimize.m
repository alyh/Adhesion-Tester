clear;
iMax = 2;
jMax = 3;
global initialstate
global teststate
global onvalve
onvalve=0;

for initialstate = 0:iMax
    for teststate = 1:jMax
    disp (initialstate);
    disp (teststate)
    disp ('running test');
    run(single_channel_optimization.m)
    
    end
end