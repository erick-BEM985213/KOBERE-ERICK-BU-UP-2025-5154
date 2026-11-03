%% OPTIMIZATION ASSIGNMENT - 3 PROBLEMS
% Requires: Optimization Toolbox (quadprog, linprog, fmincon)
clear; clc; close all;

%% ===================== PROBLEM 1: ECONOMIC DISPATCH =====================
% Minimize total fuel cost of 3 generators while meeting demand.
a = [0.004 0.006 0.009];      % $/MW^2 h
b = [5.3   5.5   5.8];        % $/MWh
c = [500   400   200];        % $/h
Pmin = [100 100 50];          % MW
Pmax = [600 400 200];         % MW
Pd   = 850;                   % MW demand

H = diag(2*a);  f = b(:);     % cost = 0.5*P'*H*P + f'*P + sum(c)
Aeq = ones(1,3); beq = Pd;
opts = optimoptions('quadprog','Display','off');
[P, fval] = quadprog(H, f, [], [], Aeq, beq, Pmin(:), Pmax(:), [], opts);
totalCost1 = fval + sum(c);
fprintf('--- Problem 1: Economic Dispatch ---\n');
fprintf('P1=%.2f MW, P2=%.2f MW, P3=%.2f MW, Cost=%.2f $/h\n', P, totalCost1);

% Cost versus demand
Pd_range = 300:25:1200;  cost_curve = zeros(size(Pd_range));
for k = 1:numel(Pd_range)
    Pk = quadprog(H, f, [], [], Aeq, Pd_range(k), Pmin(:), Pmax(:), [], opts);
    cost_curve(k) = 0.5*Pk'*H*Pk + f'*Pk + sum(c);
end

figure('Name','Problem 1');
subplot(1,2,1);
bar(P); xticklabels({'G1','G2','G3'});
ylabel('Power output (MW)'); title(sprintf('Optimal dispatch, demand = %d MW', Pd));
grid on;
subplot(1,2,2);
plot(Pd_range, cost_curve, 'b-', 'LineWidth', 2); hold on;
plot(Pd, totalCost1, 'ro', 'MarkerFaceColor','r');
xlabel('Demand (MW)'); ylabel('Minimum cost ($/h)');
title('Minimum cost vs demand'); legend('Cost curve','Operating point','Location','northwest');
grid on;

%% ===================== PROBLEM 2: PRODUCTION PLANNING (LP) ===============
% Maximize profit from products x1, x2 subject to resource limits.
profit = [40 30];                 % $/unit
A = [2 1;                         % machine hours
     1 1;                         % labour hours
     1 0];                        % raw material limit on product 1
bb = [100; 80; 40];
lb = [0; 0];
lpopts = optimoptions('linprog','Display','off');
[x, negProfit] = linprog(-profit, A, bb, [], [], lb, [], lpopts);
fprintf('--- Problem 2: Production Planning ---\n');
fprintf('x1=%.2f, x2=%.2f, Max profit=%.2f $\n', x, -negProfit);

figure('Name','Problem 2'); hold on;
x1 = linspace(0,60,200);
plot(x1, 100-2*x1, 'r-', 'LineWidth',1.5);
plot(x1, 80-x1,   'g-', 'LineWidth',1.5);
plot([40 40], [0 80], 'm-', 'LineWidth',1.5);
V = [0 0; 40 0; 40 20; 20 60; 0 80];             % feasible region vertices
fill(V(:,1), V(:,2), [0.8 0.9 1], 'FaceAlpha',0.5, 'EdgeColor','none');
for z = [1500 2000 -negProfit*-1]                 % iso-profit lines
    plot(x1, (z - 40*x1)/30, 'k--');
end
plot(x(1), x(2), 'ko', 'MarkerFaceColor','y', 'MarkerSize',9);
text(x(1)+1, x(2)+2, sprintf('Optimum (%.0f, %.0f)\nProfit = $%.0f', x, -negProfit));
xlim([0 60]); ylim([0 100]);
xlabel('x_1 (units of product 1)'); ylabel('x_2 (units of product 2)');
title('Feasible region and optimal solution');
legend('2x_1+x_2 \leq 100','x_1+x_2 \leq 80','x_1 \leq 40','Feasible region', ...
       'Iso-profit lines','','','Optimum','Location','northeast');
grid on;

%% ===================== PROBLEM 3: MINIMUM-MATERIAL CAN ===================
% Minimize surface area of a closed cylinder with fixed volume V.
V0 = 500;                                         % cm^3
areaFun = @(z) 2*pi*z(1)^2 + 2*pi*z(1)*z(2);      % z = [r h]
nonl = @(z) deal([], pi*z(1)^2*z(2) - V0);        % equality constraint
z0 = [3 10];  lb3 = [0.1 0.1];
fopts = optimoptions('fmincon','Display','off','Algorithm','sqp');
[zopt, Amin] = fmincon(areaFun, z0, [], [], [], [], lb3, [], nonl, fopts);
fprintf('--- Problem 3: Cylindrical Can ---\n');
fprintf('r=%.3f cm, h=%.3f cm (h/r=%.2f), Min area=%.2f cm^2\n', zopt, zopt(2)/zopt(1), Amin);

r = linspace(1.5, 9, 300);
Ar = 2*pi*r.^2 + 2*V0./r;                         % h eliminated using the volume constraint
figure('Name','Problem 3');
subplot(1,2,1);
plot(r, Ar, 'b-', 'LineWidth',2); hold on;
plot(zopt(1), Amin, 'ro', 'MarkerFaceColor','r');
xlabel('Radius r (cm)'); ylabel('Surface area (cm^2)');
title('Surface area vs radius (V = 500 cm^3)'); grid on;
legend('A(r)','Minimum');
subplot(1,2,2);
plot(r, V0./(pi*r.^2), 'k-', 'LineWidth',2); hold on;
plot(zopt(1), zopt(2), 'ro', 'MarkerFaceColor','r');
xlabel('Radius r (cm)'); ylabel('Height h (cm)');
title('Height required to keep V constant'); grid on;
