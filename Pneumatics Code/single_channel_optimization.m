
%Optimization Test


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
    
    pneumatics=serial('COM5');
pneumatics.BaudRate=19200;
fopen(pneumatics);
pause(2)

%% find 0 point manually?

%% configure pressure properties

fprintf (pneumatics,'<PSP,20>');
fprintf (pneumatics,'<NSP,-20>');

%% start recording

%% Assign Initial Channel State
% close all ouput valves
for i=0:7
    fprintf (pneumatics, '<VO,%d,0>',i');
end

% close all input valves
for i=0:2
    fprintf (pneumatics, '<VI,%d,0>',i');
end

%open received initial input valves
fprintf (pneumatics, '<VI,%d,1>', initialistate);
%open received initial output valves
fprintf (pneumatics, '<VO,%d,1>', onvalve);

%% move surfaces together
disp('moving together');
 fprintf(step_motor, 'TA 0.1'); % acceleration time (s)
 fprintf(step_motor, 'TD 0.1'); % de-accerleration time (s)
 fprintf(step_motor, 'VS 339'); % starting velocity (56 = 10um/s)
 fprintf(step_motor, 'VR 339'); % running velocity
 fprintf(step_motor, 'DIS 5000'); % distance to travel
 fprintf(step_motor, 'MI'); % start motion

pause (5000/339);


%% Set Channels to Test State
disp('Setting Channels to Test State');

% close all ouput valves
for i=0:7
    fprintf (pneumatics, '<VO,%d,0>',i');
end
% close all input valves
for i=0:2
    fprintf (pneumatics, '<VI,%d,0>',i');
end

%open received initial input valves
fprintf (pneumatics, '<VI,%d,1>', teststate);
%open received initial output valves
fprintf (pneumatics, '<VO,%d,1>', onvalve);

pause (30);

%% pull surfaces apart
fprintf(step_motor, 'VS 339');
fprintf(step_motor, 'VR 339');
fprintf(step_motor, 'DIS -5000'); % distance to travel
fprintf(step_motor, 'MI'); % start motion
pause (5000/339);
disp('test is done!')


fclose(force_gauge)
fclose(step_motor)
fclose(pneumatics)
delete(instrfind)
