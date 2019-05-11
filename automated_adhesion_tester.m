%% setup serial connections

% Connect Force Gauge
force_gauge = serial('/dev/tty.SLAB_USBtoUART');
force_gauge.Baudrate = 115200;
fopen(force_gauge);

% Connect Step Motor
step_motor = serial('/dev/tty.usbserial-FTTAGLYU');
fopen(step_motor);
step_motor.RecordDetail ='Verbose';
record(step_motor)
%% run tests and write force curves to a csv in 'data' folder

data = run_force_test(6,force_gauge,step_motor);
writematrix(data,['data/',datestr(now,'mm-dd-yyyy HH:MM'),'- 7mm sample - 6N preload.csv'])

%% moves step motor back to allow sample to be changed

fprintf(step_motor, 'VS 10000'); % starting velocity
fprintf(step_motor, 'VR 10000'); % running velocity
fprintf(step_motor, 'DIS -120000'); % distance to travel
fprintf(step_motor, 'MI'); % start motion

%% moves step motor back to substrate (with some give)

fprintf(step_motor, 'VS 10000'); % starting velocity
fprintf(step_motor, 'VR 10000'); % running velocity
fprintf(step_motor, 'DIS 119500'); % distance to travel
fprintf(step_motor, 'MI'); % start motion

%% close serial connnections

fclose(step_motor);
fclose(force_gauge);

%% clear connections if there's an error or old open one

if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind);
end