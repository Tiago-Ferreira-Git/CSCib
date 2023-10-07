close all
clear all
myDir = pwd; %gets directory
myDir = fullfile(myDir,'2nd session/Validation');
myFiles = dir(fullfile(myDir,'*.mat')); 


model_order = 10;


models = cell(length(myFiles),model_order-1);
results = zeros(length(myFiles),model_order-1);


plots = false;


for k = 1:length(myFiles)
    baseFileName = myFiles(k).name;
    fullFileName = fullfile(myDir, baseFileName);
    fprintf(1, 'Now reading %s - k = %d', baseFileName,k);

    load(fullFileName);
    plots = false;
    t_ignore = 11; % ignore first 10 seconds
    
  


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
    
    if(plots)
        %Plot of (utrend,ydetrend,alpha) -
        figure
        hold on
        subplot(3,1,1)
        plot(t,utrend);
        ylim([-2 2])
        xlabel('Time [s]')
        ylabel('u [V]')
        subplot(3,1,2)
        plot(t,y);
        xlabel('t')
        ylabel('y [º]')
        subplot(3,1,3)
        plot(t,alphae);
        xlabel('t')
        ylabel('\alpha [º]')
        hold off
    end
    
    figure
    for af = 0.1:0.2:1
    %af = 1/(1+Ts);
        Afilt = [1 -af];
        Bfilt = (1-af)*[1 -1];
        % Filtering
        yf = filter(Bfilt,Afilt,y);
        
        if(true)
            %Plot of (utrend,yf) - y filtered
            hold on
            % subplot(2,1,1)
            % plot(t,utrend);
            % subplot(2,1,2)
            plot(t,yf,'DisplayName',num2str(af));
            ylabel('yf')
            hold off
        end
    end
    legend show
    z = [yf u];

    if k == 1
        data = iddata(yf,u,Ts);
    else 
        data(:,:,:,baseFileName) = iddata(yf,u,Ts);
    end

    
    % for i = 2:model_order
    % 
    %     na = i; % na is the order of the polynomial A(q), specified as an Ny-by-Ny matrix of nonnegative integers
    %     nb = i-1; % nb is the order of the polynomial B(q) + 1, specified as an Ny-by-Nu matrix of nonnegative integers
    %     nc = na; % nc is the order of the polynomial C(q), specified as a column vector of nonnegative integers of length Ny
    %     nk = 1; % nk is the input-output delay, also known at the transport delay, specified as an Ny-by-Nu matrix of nonnegative integers. nk is represented in ARMAX models by fixed leading zeros of the B polynomial
    %     nn = [na nb nc nk];
    %     th = armax(z,nn); % th is a structure in identification toolbox format
    % 
    % 
    %     % Validate and qualify the obatined model
    %     [den1,num1] = polydata(th);
    %     yfsim = filter(num1,den1,u); % Equivalent to idsim(u,th)
    % 
    %     [~,performance_measurement,~] = compare(z,th);
    % 
    %     if(plots)
    %         figure
    %         compare(z,th);
    %     end
    % 
    %     models{k, i-1} = th;
    %     results(k, i-1) = performance_measurement;
    % 
    % end
    % 
    % 
    % figure
    % bar(2:model_order,results(k,:))
    % xlabel("Model Order")
    % ylabel("Performance")
    % h = title(sprintf('File name:%s\n', baseFileName));
    % set(h,'Interpreter','none');


    if(plots)
        %Plot of (yf,yfsim), yfsim - result of model applied to the data
        figure
        hold on
        plot(t,yf)
        plot(t,yfsim)
        legend({'yf','yfsim'})
        hold off
    end


    %Add integrator
    [num,den] = eqtflength(num1,conv(den1,[1 -1]));

    %convert to state-space model
    [A,B,C,D] = tf2ss(num,den);
    pause(5)


end

%%
% close all
% 
% myDir = pwd; %gets directory
% myDir = fullfile(myDir,'2nd session/Validation');
% myFiles = dir(fullfile(myDir,'*.mat')); 
% 
% 
% i = 5;
% 
% na = i; % na is the order of the polynomial A(q), specified as an Ny-by-Ny matrix of nonnegative integers
% nb = i-1; % nb is the order of the polynomial B(q) + 1, specified as an Ny-by-Nu matrix of nonnegative integers
% nc = na; % nc is the order of the polynomial C(q), specified as a column vector of nonnegative integers of length Ny
% nk = 1; % nk is the input-output delay, also known at the transport delay, specified as an Ny-by-Nu matrix of nonnegative integers. nk is represented in ARMAX models by fixed leading zeros of the B polynomial
% nn = [na nb nc nk];
% 
% model = armax(data,nn);
% 
% for k = 1:length(myFiles)
%     baseFileName = myFiles(k).name;
%     fullFileName = fullfile(myDir, baseFileName);
%     fprintf(1, 'Now reading %s\n', fullFileName);
%     compare_file(model,baseFileName);
% end

%%


Ts = 1/50;

af = 0.02;

a = (1-af)/(af*Ts);

a = a/(2*pi)



