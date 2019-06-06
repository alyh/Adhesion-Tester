running_test = true;

paused = false;
pause_time = 0;
pause_target = 50;

approach = true;
dwell = false;
retract = false;
test_done = false;

data = zeros(10,1);
count = 1;

reading_delay = 0.33;

fprintf(step_motor, 'TA 0.1'); % acceleration time (s)
fprintf(step_motor, 'TD 0.1'); % de-accerleration time (s)
fprintf(step_motor, 'VS %s \n',num2str(approachrate)); % starting velocity (56 = 10um/s)
fprintf(step_motor, 'VR %s \n',num2str(approachrate)); % running velocity

%% initial state is negative 
fprintf(pneumatics,'<VO,0,1>');
fprintf(pneumatics,'<VI,0,1>');
fprintf(pneumatics,'<VI,1,0>');
fprintf(pneumatics,'<VI,2,0>');
pause(5)

while(running_test)
    
    % record force
    fprintf(force_gauge,char('?',13,10));
    resp = fscanf(force_gauge);
    current_force = str2double(resp(1:end-3));

    data(count) = current_force;
    count = count + 1;
    
    if ~paused && approach
        disp('Moving Surfaces together');
        fprintf(step_motor, 'DIS 5000'); % distance to travel
        fprintf(step_motor, 'MI'); % start motion
        
        pause_target = round(double(5000/approachrate)/reading_delay); % need to make this 5000/approach rate
        approach = false;
        dwell = true;
        paused = true;
        
    elseif ~paused && dwell
        disp ('Surfaces are now together');
        disp('Sitting at positive pressure for 60s');
        fprintf(pneumatics,'<VI,0,0>');
        fprintf(pneumatics,'<VI,2,1>');
        
        
        pause_target = 60/reading_delay; % dwell time 60s right now
        dwell = false;
        retract = true;
        paused = true;
        
    elseif ~paused && retract
        disp ('Pulling surfaces apart');
        fprintf(step_motor, 'DIS -5000'); % distance to travel
        fprintf(step_motor, 'MI');
        
        pause_target = round(double(5000/approachrate)/0.33);
        retract = false;
        paused = true;
        test_done = true;
        
    elseif ~paused && test_done
        running_test = false;
        
    elseif paused
        pause_time = pause_time + 1;
        if pause_time >= pause_target
            paused = false;
            pause_time = 0;
        end
    end
    
    pause(reading_delay);
end
compiledmatrix(testnumber,:) = [ psp, repeatnumber, min(data), max(data)] 

writematrix(data,['data/',datestr(now,'mm-dd-yyyy-HHMM'),'-EAtest',num2str(psp),'-',num2str(repeatnumber),'.csv'])%change this to say what pressure is and what number test this is

disp('Test done!')