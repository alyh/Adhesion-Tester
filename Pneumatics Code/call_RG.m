delete(instrfind)
clear;
iMax = 2;
nrepeats = 3;
global repeatnumber;
global initialstate
global teststate
global onvalve
onvalve=0;
global force_gauge;
global step_motor;
global pneumatics;
global dwelltime;
global compiledmatrix;
global testnumber;
global psp;
global nsp;
testnumber=1;
compiledmatrix=zeros(9,4);
%% INPUT VARIABLES
psp=15;
nspinitial=-5;
nspstep=-5;
nspmax=-25;
nsp=0; %negative pressure setpoint
dwelltime=5; %time sitting in contact state before retraction
%-------------------
approachrate_um =60*3;
retractrate_um = 60*3;
global approachrate;
global retractrate;
approachrate = int16(approachrate_um*5.65);
retractrate = int16(retractrate_um*5.65);
%% connect everything
    % These serial ports should be changed depending on the computer

    % Connect Force Gauge
   
    force_gauge = serial('COM6');
    force_gauge.Baudrate = 115200;
    fopen(force_gauge);

    % Connect Step Motor
   
    step_motor = serial('COM7');
    fopen(step_motor);
    step_motor.RecordDetail ='Verbose';
    record(step_motor)
    

pneumatics =serial('COM5');
pneumatics.BaudRate=19200;
fopen(pneumatics);
disp('devices connected');
pause(2)

fprintf (pneumatics,'<PSP,%d>',psp);
fprintf (pneumatics,'<NSP,%d>',nsp);

fprintf('setting positive pressure to %d KPa \n',psp);
fprintf('setting negative pressure to %d KPa \n',nsp);
pause (10);
%% Run tests
for nsp = nspinitial:nspstep:nspmax
    for repeatnumber = 1:nrepeats
        fprintf(pneumatics,'<NSP,%d>',nsp);
        fprintf('Setpoint Pressure: %d KPa \n',nsp);
        fprintf('Repeat Number: %d \n',repeatnumber);
        pause(5)
    run('RG_test_with_force')
    
    testnumber=testnumber+1;
    end
end
writematrix(compiledmatrix,['data/',datestr(now,'mm-dd-yyyy-HHMM'),'compileddata.csv'])
disp('all tests done, setting setpoints to 0, exhausting and disconnecting');
fprintf (pneumatics,'<PSP,0>');
fprintf (pneumatics,'<NSP,0>');
for i=0:7
    fprintf (pneumatics, '<VO,%d,1>',i');
end
for i=0:2
    fprintf (pneumatics, '<VI,%d,1>',i');
end
pause(10)
for i=0:7
    fprintf (pneumatics, '<VO,%d,0>',i');
end
for i=0:2
    fprintf (pneumatics, '<VI,%d,0>',i');
end

fclose(force_gauge)
fclose(step_motor)
fclose(pneumatics)
delete(instrfind)
disp('done');