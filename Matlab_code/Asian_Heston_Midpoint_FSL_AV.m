%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% File: Asian_Heston_Midpoint_FSL_AV.m
%
% Purpose: Monte Carlo simulation of the Heston model by a Midpoint Full
% Stochastic Lawson scheme with antithetic variance reduction
% technique to price Asian Options
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
function [type , arithmetic_price , geometric_price ,arithmetic_std , geometric_std , elapsed_time ] =Asian_Heston_Midpoint_FSL_AV (S0 ,r,V0 ,K,T,type ,kappa ,theta ,sigma ,rho ,Nt ,Nsim ,R)
tic
% Prepare input parameters to call Matlab function MidpointFSLVectorized
tspan =[0,T];
X0=[S0;V0];
ExpMatrixB =cell (2);
ExpMatrixB {1}=@(p,dW) RotMatExpdW (p,dW);
ExpMatrixB {2}=@(p,dW) RotMatExpdW (p,dW);
% Calculate g1 and g2
g{1}=@(x)[sqrt(x(2 ,:)).*x(1 ,:);zeros (1, size(x ,2))];
g{2}=@(x)[zeros (1, size(x ,2));sigma*sqrt(x(2 ,:))];
% g{1} = @(x)[sqrt(real(x(2 ,:))).*x(1 ,:);sigma*rho*sqrt(real(x(2 ,:)))];
% g{2} = @(x)[zeros(1,size(x,2));sigma*sqrt((1 -(rho^2))*real(x(2 ,:)))];
gJac {1}=@(x) getgJac1 (x);
gJac {2}=@(x) getgJac2 (x);
B=cell (2);
Bexp=cell (2);
B{1}= zeros (2);
B{2}= zeros (2);
Bexp {1} = @(W) ExpMatrixB {1}(0 ,W);
Bexp {2} = @(W) ExpMatrixB {1}(0 ,W);
h = T/Nt;
% Generate Brownian Motions
rng('default');
Z1 = randn(Nt ,Nsim);
Z2 = randn(Nt ,Nsim);
dW1 = cell (2 ,1);
dW1 {1} = sqrt(h)*Z1;
dW1 {2} = rho*dW1 {1} + sqrt(h)*sqrt (1 - rho ^2)*Z2;
% Generate Brownian Motions for antithetic paths
dW2 = cell (2 ,1);
dW2 {1} = -dW1 {1};
dW2 {2} = rho*dW2 {1} + sqrt(h)*sqrt (1 - rho ^2)*-Z2;
A=[r,0;0,- kappa ];
g0 =@(x) getg0(x);
g0Jac =@(x) getgJac0(x);
% Generate asset price at maturity
[~,S1 ,~] = MidpointFSLVectorized (X0 ,A,g0 ,B,g,tspan ,h,dW1 ,g0Jac,gJac ,Bexp); 
% returns price and volatility paths
[~,S2 ,~] = MidpointFSLVectorized (X0 ,A,g0 ,B,g,tspan ,h,dW2 ,g0Jac,gJac ,Bexp); 
% returns price and volatility paths
S1 = real(S1);
S2 = real(S2);
% Calculate average price throughout option life
arithmetic_mean = zeros (1, Nsim);
antithetic_arithmetic_mean = zeros (1, Nsim);
geometric_mean = zeros (1, Nsim);
antithetic_geometric_mean = zeros (1, Nsim);
for i = 1: Nsim
        arithmetic_mean (i) = mean(S1 (2:end,i));
    antithetic_arithmetic_mean (i) = mean(S2 (2:end,i));
    geometric_mean (i) = geomean(S1 (2:end,i));
    antithetic_geometric_mean (i) = geomean(S2 (2:end,i));
end
% calculate payoffs for each path
if strcmp(type ,'call')
    arithmetic_payoff = max( arithmetic_mean - K ,0);
    antithetic_arithmetic_payoff = max(antithetic_arithmetic_mean - K ,0);
    geometric_payoff = max( geometric_mean - K ,0);
    antithetic_geometric_payoff = max(antithetic_geometric_mean - K ,0);
else
    arithmetic_payoff = max(k - arithmetic_mean ,0);
    antithetic_arithmetic_payoff = max(K - antithetic_arithmetic_mean ,0);
    geometric_payoff = max(K - geometric_mean ,0);
    antithetic_geometric_payoff = max(k - antithetic_geometric_mean ,0);
end
% calculate payoffs mean and discount
arithmetic_price = R*mean( arithmetic_payoff );
geometric_price = R*mean( geometric_payoff );
anithetic_arithmetic_price = R*mean(antithetic_arithmetic_payoff );
anithetic_geometric_price = R*mean( antithetic_geometric_payoff);
arithmetic_price = 0.5*( arithmetic_price +anithetic_arithmetic_price );
geometric_price = 0.5*( geometric_price + anithetic_geometric_price );
arithmetic_std = 0.5* sqrt(std( arithmetic_payoff )^2+ std(antithetic_arithmetic_payoff )^2);
geometric_std = 0.5* sqrt(std( geometric_payoff )^2+ std(antithetic_geometric_payoff )^2);
elapsed_time = toc;
%% Functions for calling Midpoint FSL
function [erg ,inverg ]= RotMatExpdW (lambda ,dW)
    %Calculate Matrix exponentials expm( [0 -lambda;lambda 0]*dW(i)) and their
    %inverses and save them in erg(:,:,i) and inverg(:,:,i), respectively.
    erg=zeros (2,2, length(dW));
    inverg=zeros(size(erg));
    temp1=cos(lambda*dW);
    temp2=sin(lambda*dW);
    erg (1 ,1 ,:)=temp1;
    erg (2 ,2 ,:)=temp1;
    erg (1 ,2 ,:)=-temp2;
    erg (2 ,1 ,:)=temp2;
    inverg (1 ,1 ,:)=temp1;
    inverg (2 ,2 ,:)=temp1;
    inverg (1 ,2 ,:)=temp2;
    inverg (2 ,1 ,:)=-temp2;
end
function result=getg0(x)
    result=ones(size(x));
    result (1 ,:) =0* result (1 ,:);
    result (2 ,:)=result (2 ,:)*kappa*theta;
end
function result=getgJac0(x)
    nw=size(x ,1);
    P=size(x ,2);
    result=zeros(nw ,nw ,P);
end
function result=getgJac1(x)
    nw=size(x ,1);
    P=size(x ,2);
    result=zeros(nw ,nw ,P);
    result (1 ,1 ,:)=sqrt(x(2 ,:));
    result (1 ,2 ,:)=x(1 ,:) ./(2* sqrt(x(2 ,:)));
end
function result=getgJac2(x)
    nw=size(x ,1);
    P=size(x ,2);
    result=zeros(nw ,nw ,P);
    result (2 ,2 ,:)=sigma ./(2* sqrt(x(2 ,:)));
end
end