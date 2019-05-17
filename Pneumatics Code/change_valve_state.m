function [] = change_valve_state(input_state,output_state)
    % close all output valves
    for i=0:7
        fprintf (pneumatics, '<VO,%d,0>',i');
    end

    % close all input valves
    for i=0:2
        fprintf (pneumatics, '<VI,%d,0>',i');
    end

    %open received initial input valves
    fprintf (pneumatics, '<VI,%d,1>', input_state);
    %open received initial output valves
    fprintf (pneumatics, '<VO,%d,1>', output_state);
end