function [force_gauge, step_motor] = connect_instruments()
%connect_instruments Connects Mark-10 force gauge and step motor

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

 fprintf(step_motor, 'TA 0.1'); % acceleration time (s)
 fprintf(step_motor, 'TD 0.1'); % de-accerleration time (s)
 fprintf(step_motor, 'VS 1000'); % starting velocity (56 = 10um/s)
 fprintf(step_motor, 'VR 1000'); % running velocity
 fprintf(step_motor, 'DIS 5000'); % distance to travel
 fprintf(step_motor, 'MI'); % start motion
end

