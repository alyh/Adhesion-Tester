
%EA Test


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
fprintf (pneumatics,'<PSP,5>');
fprintf (pneumatics,'<NSP,-15>');

%% start recording
 fprintf(force_gauge,char('?',13,10));
        resp = fscanf(force_gauge);
        current_force = str2double(resp(1:end-3));
data = run_force_test(6,force_gauge,step_motor);
writematrix(data,['data/',datestr(now,'mm-dd-yyyy HH:MM'),'- 7mm sample - 6N preload.csv'])

%% open output valve and open exhuast then wait 10s
fprintf (pneumatics,'<VO,0,1>');
fprintf (pneumatics,'<VI,0,0>');
fprintf (pneumatics,'<VI,1,1>');
disp('dwelling at neutral pressure for 10s');
pause (10);

%% close exhuast and open positive valve then do a 60s preload
fprintf (pneumatics,'<VI,1,0>');
fprintf (pneumatics,'<VI,2,1>');
disp('dwelling at positive pressure for 60s');
pause(10);
%% run test
disp('starting retraction');
 fprintf(step_motor, 'TA 0.1'); % acceleration time (s)
 fprintf(step_motor, 'TD 0.1'); % de-accerleration time (s)
 fprintf(step_motor, 'VS 339'); % starting velocity (56 = 10um/s)
 fprintf(step_motor, 'VR 339'); % running velocity
 fprintf(step_motor, 'DIS -5000'); % distance to travel
 fprintf(step_motor, 'MI'); % start motion
%how to i know when the motion stops
pause (5000/339);
disp('starting return to initial state');

%% test is over, return to negative state for reset
fprintf (pneumatics,'<VI,1,1>');
fprintf (pneumatics,'<VI,2,0>');
pause(1);
fprintf (pneumatics,'<VI,1,0>');
fprintf (pneumatics,'<VI,0,1>');
fprintf(step_motor, 'VS 678');
fprintf(step_motor, 'VR 678');
fprintf(step_motor, 'DIS 5000'); % distance to travel
fprintf(step_motor, 'MI'); % start motion
pause (5000/339);
disp('test is done!')
fclose(force_gauge)
fclose(step_motor)
fclose(pneumatics)
delete(instrfind)

