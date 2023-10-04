function [output] = compare_file(th,baseFileName)
    
    myDir = pwd; %gets directory
    myDir = fullfile(myDir,'2nd session');
    myFiles = dir(fullfile(myDir,'*.mat')); 
    
    fullFileName = fullfile(myDir, baseFileName);

    fprintf(1, 'Now reading %s\n', fullFileName);

    load(fullFileName);

    t_ignore = 20; % ignore first 10 seconds
    fs = 1/(t(2)-t(1));



    t = out.time;
    t = t(t_ignore * fs:end,1);
    
    
    u = u(t_ignore * fs:end,1);
    
    sigs = out.signals.values;
    utrend = sigs(t_ignore * fs:end,1); % Entrada - Input signal
    thetae = sigs(t_ignore * fs:end,2); % Potenciómetro - Potentiometer signal
    alphae = sigs(t_ignore * fs:end,3); % Extensómetro - Strain gage signal

    
    
    y_trend = thetae + alphae;
    
    u = detrend(utrend);
    y = detrend(y_trend);
    

    
    af = 0.8;
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