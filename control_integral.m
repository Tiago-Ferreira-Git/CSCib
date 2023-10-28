clear all;
close all;

load('model.mat')

n = size(A,1);


C_ = C;
A = [A zeros(n,1); -C_ 1];
B = [B ; 0];
C = [C_ 0];






% figure
% sys = ss(A,B,C,D,0.02)
% [num,den] = ss2tf(A,B,C,D);
% num = conv(num,fliplr(num));
% den = conv(den,fliplr(den));
% sys = tf(num,den,-1);
% rlocus(sys)
% zgrid
% axis('equal')


Q = C'*C;
Q(n+1,n+1) = 0.001;


R = 20;

K = dlqr(A,B,Q,R);
eig(A-B*K)
Ki = -K(end);
K = K(1:end-1);

load('model.mat')
D = zeros(size(A,1),1);
Q_w = 100*eye(n);
R_v = 1;

G = eye(n);
N = inv(C*inv(eye(n)-A+B*K)*B);
L = dlqe(A,G,C,Q_w,R_v);
x0 = [0 0 0 0 0 0];
C = eye(6);
N = inv(C_*inv(eye(n)-A+B*K)*B);
T=20; % Time duration of the simulation
sim('statefdbk_integral',T);

figure;
hold on 
gg=plot(y.time,y.signals.values(:,1));
set(gg,'LineWidth',1.5)
gg=plot(Ref.time,Ref.signals.values(:,1));
set(gg,'LineWidth',1.5)
gg=xlabel('Time [s]');
set(gg,'Fontsize',14);
gg=ylabel('y');
set(gg,'Fontsize',14);
hold off


%est_error = x_hat - x;
%sum(sqrt(est_error(:,1).^2 + est_error(:,2).^2 + est_error(:,3).^2 + est_error(:,4).^2 + est_error(:,5).^2 + est_error(:,6).^2 ))

% figure;
% gg=plot(x_hat.time,x_hat.signals.values(:,1),x.time,x.signals.values(:,1));
% set(gg,'LineWidth',1.5)
% gg=xlabel('Time [s]');
% set(gg,'Fontsize',14);
% gg=ylabel('State');
% set(gg,'Fontsize',14);
% hl = legend('$\hat{x}$','$x$');
% set(hl, 'Interpreter', 'latex');
% hl = legend('$\alpha$','$\beta$');
% set(hl, 'Interpreter', 'latex');


figure;
gg=plot(u.time,u.signals.values(:,1));
set(gg,'LineWidth',1.5)
gg=xlabel('Time [s]');
set(gg,'Fontsize',14);
gg=ylabel('u [V]');
set(gg,'Fontsize',14);
hl = legend('u');
set(hl, 'Interpreter', 'latex');

eig(A-B*K)