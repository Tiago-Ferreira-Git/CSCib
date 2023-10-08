close all
clear all
myDir = pwd; %gets directory
myDir = fullfile(myDir,'2nd session/Training');
myFiles = dir(fullfile(myDir,'*.mat')); 

num_exp_test = 16;


for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    fprintf(1, 'Now reading %s - k = %d\n', baseFileName,k);

    load(fullFileName,'u','out');
    plots = false;
    t_ignore = 10; % ignore first 10 seconds
    
  

    % Load and parse training models
    t = out.time;
    fs = 1/(t(2)-t(1));
    Ts = t(2)-t(1);
    t = t(t_ignore * fs:end,1);
    
    
    u = u(t_ignore * fs:end,1);
    
    sigs = out.signals.values;
   
    utrend = sigs(t_ignore * fs:end,1); % Entrada - Input signal
    thetae = sigs(t_ignore * fs:end,2); % Potenciómetro - Potentiometer signal
    alphae = sigs(t_ignore * fs:end,3); % Extensómetro - Strain gage signal

    
    
    y_trend = thetae + alphae;
    
    u = detrend(utrend);
    y = detrend(y_trend);
    
    % Filter
    af = 0.7;
    Afilt = [1 -af];
    Bfilt = (1-af)*[1 -1];

    yf = filter(Bfilt,Afilt,y);

    
    z = [yf u];



    % Append all the models
    if k == 1
        data = iddata(yf,u,Ts);
    else 
        data(:,:,:,baseFileName) = iddata(yf,u,Ts);
    end

    if(k == num_exp_test)
        file = fullFileName;
    end


end


%% 
close all
myDir = pwd; %gets directory
myDir = fullfile(myDir,'2nd session/Validation');
myFiles = dir(fullfile(myDir,'*.mat')); 



% Selection of model's order

i = 5;
na = i; % na is the order of the polynomial A(q), specified as an Ny-by-Ny matrix of nonnegative integers
nb = i-1; % nb is the order of the polynomial B(q) + 1, specified as an Ny-by-Nu matrix of nonnegative integers
nc = na; % nc is the order of the polynomial C(q), specified as a column vector of nonnegative integers of length Ny
nk = 1; % nk is the input-output delay, also known at the transport delay, specified as an Ny-by-Nu matrix of nonnegative integers. nk is represented in ARMAX models by fixed leading zeros of the B polynomial
nn = [na nb nc nk];


% Get the model
model = armax(data,nn)
for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    load(fullFileName,'out')

    t = out.time;
    sigs = out.signals.values;
    utrend = sigs(1:end,1);
    
    
    thetae = sigs(1:end,2); % Potenciómetro - Potentiometer signal
    alphae = sigs(1:end,3); % Extensómetro - Strain gage signal
    
    u = utrend;
    y = detrend(thetae + alphae);
            
    
    [den1,num1] = polydata(model);
    yfsim = filter(num1,den1,u); % Equivalent to idsim(u,th)
    
     %Add integrator
    [num,den] = eqtflength(num1,conv(den1,[1 -1]));
    
    %convert to state-space model
    [A,B,C,D] = tf2ss(num,den);
    pause(5)
    SS = ss(A,B,C,D, 0.02);

    
    
    
    
    %y_dlsim = lsim(SS,u,t,y(1));
    %y_dlsim = compare(SS,z_test);
    
    y_dlsim = dlsim(A,B,C,D,u);
    y_dlsim = detrend(y_dlsim);
    figure
    hold on
    t = t(20*fs:end);
    y = y(20*fs:end);
    y_dlsim = y_dlsim(20*fs:end);
    plot(t,y,'DisplayName','Real')
    plot(t,y_dlsim,'DisplayName','Sim')
    xlim([20 40])
    ylabel('y [º]')
    xlabel('t [s]')
    grid on;
    %plot(t,Dy_sim,'DisplayName','Sim')
    
    legend show

end

%%
freqz(num,den,256,fs)
figure
zplane(num,den)


