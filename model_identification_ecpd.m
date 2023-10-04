%%
myDir = pwd; %gets directory
myDir = fullfile(myDir,'2nd session');
myFiles = dir(fullfile(myDir,'*.mat')); 


baseFileName = "rbs_1v_6hz.mat";


fullFileName = fullfile(myDir, baseFileName);
fprintf(1, 'Now reading %s\n', fullFileName);

load(fullFileName);


t_ignore = 20; % ignore first 10 seconds
fs = 50;



n = 6;
sys = ssest(u,y,n,'Ts',1/fs);
[A,B,C,~,Ke] = idssdata(sys);
 
% Initializations
N = length(u);
Dy_sim = nan(1,N);
Dx_sim = nan(n,N);

% Find initial incremental state that best fits the data given the identified model
x0 = findstates(sys,iddata(y,u,1/fs));

% Set initial conditions
% Dy_sim(:,1) = y(:,1);
Dx_sim(:,1) = x0;

% Propagate model
for k = 1:N-1
    Dx_sim(:,k+1) = A*Dx_sim(:,k) + B*u(k,1);
    Dy_sim(:,k+1) = C*Dx_sim(:,k+1);
end


% Plot results
figure('Units','normalized','Position',[0.2 0.5 0.3 0.4]);
subplot(2,1,1), hold on, grid on   
title(sprintf('Model performance (n=%d) on identification dataset',n))
plot(t,y,'.','MarkerSize',5)
plot(t,Dy_sim,'g--')
xlabel('Time [s]')
ylabel('\Delta y [°C]')
xlim([t(1),t(end)]);
legend('Experimental data','Model','Location','best');
subplot(2,1,2), hold on, grid on   
stairs(t,u,'LineWidth',2)
xlabel('Time [s]')
ylabel('\Delta u [%]')
xlim([t(1),t(end)]);
