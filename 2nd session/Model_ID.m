t = ScopeData.time;
sigs = ScopeData.signals.values;

utrend = sigs(:,1); % Entrada - Input signal
thetae = sigs(:,2); % Potenciómetro - Potentiometer signal
alphae = sigs(:,3); % Extensómetro - Starin gage signal

% Reconstrução ângulo total da barra – Computation of total bar angle
ytrend = thetae*Kp + alphae*Ke;

af = 0.8;
Afilt = [1 -af];
Bfilt = (1-af)*[1 -1];
% Filtragem seguida de eliminação de tendências
% Filtering and detrending
yf = filter(Bfilt,Afilt,ytrend);

u = detrend(utrend);

z = [yf u];
na = 3; % AR part
nb = 2; % X part
nc = na; % MA part
nk = 1; % Atraso puro – pure delay
nn = [na nb nc nk];
th = armax(z,nn); % th is a structure in identification toolbox forma

[den1,num1] = polydata(th);

yfsim = filter(num1,den1,u); % Equivalent to idsim(u,th)

[num,den] = eqtflength(num1,conv(den1,[1 -1]));

[A,B,C,D] = tf2ss(num,den);

