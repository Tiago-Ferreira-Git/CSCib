clear all;
close all;

load('model.mat')
D = zeros(size(A,1),1);
n = size(A,1);

Q = diag([1 1 1 1 1 1]);

R = 100;

K = dlqr(A,B,Q,R);

Q_w = 100*eye(n);
R_v = 1;

G = eye(n);

L = dlqe(A,G,C,Q_w,R_v);


x0 = [10 0 0 0 0 10];
C_ = C; 
C = eye(6);
T=1; % Time duration of the simulation
sim('statefdbk',T);


figure;
gg=plot(t,y(:,1));
set(gg,'LineWidth',1.5)
gg=xlabel('Time [s]');
set(gg,'Fontsize',14);
gg=ylabel('y');
set(gg,'Fontsize',14);


est_error = x_hat - x;
sum(sqrt(est_error(:,1).^2 + est_error(:,2).^2 + est_error(:,3).^2 + est_error(:,4).^2 + est_error(:,5).^2 + est_error(:,6).^2 ))

figure;
gg=plot(t,x_hat(:,1),t,x(:,1));
set(gg,'LineWidth',1.5)
gg=xlabel('Time [s]');
set(gg,'Fontsize',14);
gg=ylabel('y [rad]');
set(gg,'Fontsize',14);
hl = legend('$\hat{x}$','$x$');
set(hl, 'Interpreter', 'latex');
% hl = legend('$\alpha$','$\beta$');
% set(hl, 'Interpreter', 'latex');



% N = inv([A-eye(n,n), B; C,0])*[zeros(n,1);1];
% Nx = N(1:n,:);
% Nu = N(n,:);
% Nbar = Nu+K*Nx;