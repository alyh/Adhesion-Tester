function [data] = run_force_test(target_preload, force_gauge, step_motor)
%run_force_test Tests sample at certain preload and returns force curve

    % Set parameters of step motor
    fprintf(step_motor, 'TA 0.1'); % acceleration time (s)
    fprintf(step_motor, 'TD 0.1'); % de-accerleration time (s)
    fprintf(step_motor, 'VS 28'); % starting velocity (56 = 10um/s)
    fprintf(step_motor, 'VR 28'); % running velocity
    fprintf(step_motor, 'DIS 6000'); % distance to travel
    fprintf(step_motor, 'MI'); % start motion

    running_test = true;
    approaching = true;
    
    buffer = 0.10; % buffer for hitting target preload force
    reading_delay = 0.3; % delay between readings in seconds

    data = zeros(100,1);
    count = 1;
    
    % if we're around zero for a while, the test is probably done
    zero_time = 0;
    zero_cutoff = 80 * reading_delay; % cutoff for end of test is ~24s at 0

    dwell_time = 0;
    dwell_cutoff = 50 * reading_delay; % dwell for ~5s
    dwelling = false;

    disp('Test Started');
    while(running_test)
        % get force data from force gauge
        fprintf(force_gauge,char('?',13,10));
        resp = fscanf(force_gauge);
        current_force = str2double(resp(1:end-3));

        data(count) = current_force;
        count = count + 1;

        % if we've reached the preload, stop the motor and start dwelling
        if (current_force < target_preload+buffer) && ...
                (current_force > target_preload-buffer) && approaching
            disp(['Target Preload Reached: ',num2str(current_force)]);
            approaching = false;
            
           
            fprintf(step_motor,'SSTOP'); % slow stop = de-accelerate first
            dwelling = true;
        end

        % if we're dwelling, keep going until we reach dwell_cutoff
        if dwelling
            if dwell_time == 0
                disp(['Dwelling for ',num2str(dwell_cutoff*reading_delay),'s']);
            end
            dwell_time = dwell_time + 1;
            
            if dwell_time >= dwell_cutoff
                dwelling=false;
                
                % once we're done dwelling, move all the way back.
                fprintf(step_motor, 'DIS -7000');
                fprintf(step_motor,'MI');
                disp('Done dwelling, unadhering...');
            end
        end

        % end criteria: if we're around zero for a while stop the test
        if (current_force < 0.05) && ...
                (current_force > -0.05) && ~approaching
            zero_time = zero_time + 1;
            if zero_time >= zero_cutoff
                disp('Test complete, finishing up...');
                running_test = false;          
            end
        end

        % delay between readings (this also effects dwell time and stopping
        % criteria (eg. dwell_cutoff=15 means 15*0.3s=4.5s of dwell)
        pause(reading_delay)
    end
    disp(['DONE. Max adhesion of ',num2str(-min(data))])
    
    % test is done, stop the motor
    fprintf(step_motor,'SSTOP');
end

