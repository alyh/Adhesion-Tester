function [force_gauge, step_motor] = connect_instruments()
%connect_instruments Connects Mark-10 force gauge and step motor

    % These serial ports should be changed depending on the computer

    % Connect Force Gauge
    force_gauge = serial('/dev/tty.SLAB_USBtoUART');
    force_gauge.Baudrate = 115200;
    fopen(force_gauge);

    % Connect Step Motor
    step_motor = serial('/dev/tty.usbserial-FTTAGLYU');
    fopen(step_motor);
    step_motor.RecordDetail ='Verbose';
    record(step_motor)
end

