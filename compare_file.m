function [output] = compare_file(th,baseFileName,af)
    myDir = pwd; %gets directory
    myDir = fullfile(myDir,'2nd session/Validation');
    fullFileName = fullfile(myDir, baseFileName);

    load(fullFileName,'out','u');
    t = out.time;

    
    sigs = out.signals.values;
    utrend = sigs(:,1); % Entrada - Input signal
    thetae = sigs(:,2); % Potenciómetro - Potentiometer signal
    alphae = sigs(:,3); % Extensómetro - Strain gage signal

    
    
    y_trend = thetae + alphae;
    
    u = detrend(utrend);
    y = detrend(y_trend);
    

    
    Afilt = [1 -af];
    Bfilt = (1-af)*[1 -1];
    % Filtering
    yf = filter(Bfilt,Afilt,y);
    
    z = [yf u];
    [~,output,~] = compare(z,th);
    figure
    compare(z,th)
    t = title(sprintf('File name:%s', baseFileName));
    set(t,'Interpreter','none');
end