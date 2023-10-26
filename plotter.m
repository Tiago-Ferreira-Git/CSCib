close all
clear all

myDir = pwd; %gets directory
myDir = fullfile(myDir,'1st session');
myFiles = dir(fullfile(myDir,'*.mat')); 
error = [];
x = [];
y = [];

%% Pot calibration
for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  
  if strcmp("2st",baseFileName(1:3))
      load(fullFileName);
      error = [error ; cov(tensao_pot.signals.values)];
      x = [x ; mean(tensao_pot.signals.values)];

      newStr = split(baseFileName,"_");
      newStr = newStr(3);

      newStr = split(newStr,".");
      newStr = newStr(1);

      newStr = split(newStr,"d");
      newStr = newStr(1);

      y = [y ; str2double(newStr)];
      clear tensao_pot;
  end
end

fusion = [x error];
fusion = sortrows(fusion);


X = [ones(length(x),1) x];
b = inv(X.'*X)*X.'*y;
Y = X*b;

figure('Units','normalized','Position',[0.5 0.5 0.3 0.4])
hold on, grid on   
title('Potentiometer Calibration')
%errorbar(sort(x),sort(y),'MarkerSize',5)
plot(x,Y,'-')
plot(sort(x),sort(y),'s','MarkerSize',5,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6])    
formatSpec = 'y_{fit} = %fx + %f';
dim = [.2 .5 .3 .3];
str = sprintf(formatSpec,b(2),b(1));
annotation('textbox',dim,'String',str,'FitBoxToText','on');

legend({"y_{fit}","Measured"},'Location',"southeast")
xlabel('Voltage [V]')
ylabel('Angle [º]')


%% pot first method

baseFileName = '1st_method.mat';
fullFileName = fullfile(myDir, baseFileName);


load(fullFileName);

figure('Units','normalized','Position',[0.5 0.5 0.3 0.4])
hold on, grid on   
title('Potentiometer Calibration')
plot(tensao_pot.time,signal_generator.signals.values,'-')
plot(tensao_pot.time,tensao_pot.signals.values,'-')
hold off
legend({"Input","Output"},'Location',"southeast")
xlabel('Time [s]')
ylabel('Voltage [V]')




%% Gage Calibration
error = [];
x = [];
y = [];

for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  if strcmp("gag",baseFileName(1:3))
      load(fullFileName);
      newStr = split(baseFileName,"_");
      L = str2double(newStr(5));
      L = convlength(L,'in','m')*100;
      D = sign(tensao_gage.signals.values(2))*str2double(strcat(newStr(2), ".", newStr(3)));
      alpha = D/L;
      alpha = rad2deg(alpha);
      

      error = [error ; cov(tensao_gage.signals.values)];
      x = [x ; mean(tensao_gage.signals.values)];
      y = [y ; alpha];

      clear tensao_gage;

  end
end

X = [ones(length(x),1) x];
b = inv(X.'*X)*X.'*y;
Y = X*b;

figure('Units','normalized','Position',[0.5 0.5 0.3 0.4])
hold on, grid on   
title('Gage Calibration')
plot(x,Y,'-')
plot(sort(x),sort(y),'s','MarkerSize',5,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6])    
formatSpec = 'y_{fit} = %fx + %f';
dim = [.2 .5 .3 .3];
str = sprintf(formatSpec,b(2),b(1));
annotation('textbox',dim,'String',str,'FitBoxToText','on');

legend({"y_{fit}","Measured"},'Location',"southeast")
xlabel('Voltage [V]')
ylabel('Angle [º]')

%% Control part

close all;
clear all;




myDir = pwd; %gets directory
myDir = fullfile(myDir,'4th session');
myFiles = dir(fullfile(myDir,'*.mat')); 


figure
for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  load(fullFileName);
  newStr = split(baseFileName,"_");
  r_value = split(newStr{2},'.');
  if length(newStr) < 3
      t = 2:0.02:(-110+((length(u)-1)/4))*0.02;
      u = u(100:100+length(t)-1);
      hold on
      grid on
      plot(t,u,'DisplayName',sprintf('%s = %s',newStr{1},r_value{1}),'LineWidth',2);
      xlim([2,2.8])
      xlabel('Time [s]')
      ylabel('u [V]')
  end
end
legend show
costs = [];
for k = 1:length(myFiles)
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(myDir, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  load(fullFileName);
  t = 0:0.02:((length(u)-1))*0.02;
  newStr = split(baseFileName,"_");
  r_value = split(newStr{2},'.');
  if length(newStr) < 3
      if(~isa(Ref,'double'))
        Ref = Ref.signals.values(:,1);
      end
      figure
      subplot(2,1,1);
      hold on
      plot(t,y)
      plot(t,Ref)
      hold off
      ylim([min(Ref)-5,max(Ref)+5])
      xlabel('Time [s]')
      ylabel('y [º]')
      title(sprintf('%s = %s',newStr{1},r_value{1}))
      subplot(2,1,2); 
      plot(t,u);
      ylim([min(u)-1,max(u)+1])
      xlabel('Time [s]')
      ylabel('u [V]')

      alpha = 0.5;
      error = sum(Ref(:,1) - y(:,1))^2;
      u_energy = u' * u;
      cost = (1- alpha) * u_energy + alpha * error; 
      R = str2double(r_value{1});
      costs = [costs; cost R];
  end
end