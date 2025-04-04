%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% File: Asian_Heston_Euler_DSL_CV.m
%
% Purpose: Monte Carlo simulation of the Heston model by a Euler -
% Maruyama Drift Stochastic Lawson scheme with control
% variate variance reduction technique to price Asian
% Options
%
% Algorithm: Kristian Debrabant , Anne K v r n , Nicky Gordua Matsson.
% Runge -Kutta Lawson schemes for stochastic differential
% equations. BIT Numerical Matematics 61 (2021),381 -409.
%
% Implementation: Kristian Debrabant , Anne K v r n , Nicky Gordua Matsson.
% Matlab code: Runge -Kutta Lawson schemes for stochastic
% differential equations (2020).
% https://doi.org/10.5281/ zenodo.4062482
%
% Adapted by Nicolas Kuiper and Martin Westberg
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [type , arithmetic_price , geometric_price ,arithmetic_std , geometric_std , elapsed_time ] = Asian_Heston_Euler_DSL_CV (S0 ,r,V0 ,K,T,type ,kappa ,theta ,sigma ,rho ,Nt ,Nsim ,R)
tic
X0 = [S0; V0];
A = [r, 0; 0, -kappa ];
g0 = @(x) getg0(x,kappa ,theta);
g = cell (2, 1);
g{1} = @(x) [sqrt(x(2, :)).*x(1, :); zeros (1, size(x, 2))];
g{2} = @(x) [zeros (1, size(x, 2)); sigma * sqrt(x(2, :))];
tspan = [0, T];
h = T / Nt;
%rng('default ');
Z1 = randn(Nt , Nsim);
Z2 = randn(Nt , Nsim);
dW = cell (2, 1);
dW {1} = sqrt(h) * Z1;
dW {2} = rho * dW {1} + sqrt(h) * sqrt (1 - rho ^2) * Z2;
[~,S, ~] = EulerDSLVectorized (X0 , A, g0 , g, tspan , h, dW);

% Calculate the price of the Asian option
arithmetic_mean = zeros (1, Nsim);
geometric_mean = zeros (1, Nsim);
for i = 1: Nsim
    arithmetic_mean (i) = mean(S(2:end,i));
    geometric_mean (i) = geomean(S(2:end,i));
end
if strcmp(type ,'call')
    arithmetic_payoff = max( arithmetic_mean - K ,0);
    geometric_payoff = max( geometric_mean - K ,0);
else
    arithmetic_payoff = max(K - arithmetic_mean ,0);
    geometric_payoff = max(K - geometric_mean ,0);
end
% set the geometric payoff as control variate
CV = geometric_payoff ;
payoff = arithmetic_payoff ;
% estimate the control variate coefficient
v = var(payoff);
C = cov(CV , payoff);
b = C(1 ,2)/v;
adjusted_payoff = payoff - b*(CV - mean(CV));
arithmetic_price = R*mean( adjusted_payoff );
geometric_price = R*mean( geometric_payoff );
arithmetic_std = std( adjusted_payoff );
geometric_std = std( geometric_payoff );
elapsed_time = toc;
function result=getg0(x,kappa ,theta)
    result=ones(size(x));
    result (1 ,:) =0* result (1 ,:);
    result (2 ,:)=result (2 ,:)*kappa*theta;
end
end