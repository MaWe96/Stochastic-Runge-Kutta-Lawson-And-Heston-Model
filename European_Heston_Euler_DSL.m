% File: European_Heston_Euler_DSL.m
%
% Purpose: Monte Carlo simulation of the Heston model by a Euler -
% Maruyama Drift Stochastic Lawson scheme to price European
% Options
%
% Algorithm: Kristian Debrabant , Anne Kv{\ae}rn{\o}, Nicky
% Cordua Matsson.
% Runge -Kutta Lawson schemes for stochastic differential
% equations. BIT Numerical Matematics 61 (2021), 381 -409.
%
% Implementation: Kristian Debrabant , Anne Kv{\ae}rn{\o},
% Nicky Gordua Matsson.
% Matlab code: Runge -Kutta Lawson schemes for stochastic
% differential equations (2020).
% https://doi.org/10.5281/ zenodo.4062482
%
% Adapted by Nicolas Kuiper and Martin Westberg
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [type , option_price , std_deviation , elapsed_time ] = European_Heston_Euler_DSL (S0 ,r,V0 ,K,T,type ,kappa ,theta ,sigma ,rho ,Nt ,Nsim ,R)
tic
X0 = [S0; V0];
A = [r, 0; 0, -kappa ];
g0 = @(x) getg0(x,kappa ,theta);
g = cell (2, 1);
g{1} = @(x) [sqrt(x(2, :)).*x(1, :); zeros (1, size(x, 2))];
g{2} = @(x) [zeros (1, size(x, 2)); sigma * sqrt(x(2, :))];
tspan = [0, T];
h = T / Nt;
rng('default');
Z1 = randn(Nt , Nsim);
Z2 = randn(Nt , Nsim);
dW = cell (2, 1);
dW {1} = sqrt(h) * Z1;
dW {2} = rho * dW {1} + sqrt(h) * sqrt (1 - rho ^2) * Z2;
[~,~, X] = EulerDSLVectorized (X0 , A, g0 , g, tspan , h, dW);
% % calculate the price of the European option
if strcmp(type ,'call')
    payoff = max(X(1 ,:)-K ,0);
elseif strcmp(type ,'put')
    payoff = max(K - X(1 ,:) ,0);
end
payoff_mean = mean(payoff);
option_price = R* payoff_mean ;
std_deviation = std(payoff);
elapsed_time = toc;
function result=getg0(x,kappa ,theta)
    result=ones(size(x));
    result (1 ,:) =0* result (1 ,:);
    result (2 ,:)=result (2 ,:)*kappa*theta;
end
end