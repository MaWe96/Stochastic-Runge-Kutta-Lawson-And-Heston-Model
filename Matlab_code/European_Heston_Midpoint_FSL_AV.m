% File: European_Heston_Midpoint_FSL_AV.m
%
% Purpose: Monte Carlo simulation of the Heston model by a
% Full Stochastic Lawson scheme with Antitethic
% Variate variance reduction technique to price
% European Options
%
% Implementation: Kristian Debrabant , Anne Kv{\ae}rn{\o}{\o},
% Nicky Gordua Matsson.
% Matlab code: Runge -Kutta Lawson schemes for stochastic
% differential equations (2020).
% https://doi.org/10.5281/ zenodo.4062482
%
% Adapted by Nicolas Kuiper and Martin Westberg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [type , option_price , std_deviation , elapsed_time ] = European_Heston_Midpoint_FSL_AV (S0 ,r,V0 ,K,T,type ,kappa ,theta ,sigma ,rho ,Nt ,Nsim ,h,R)
% set random number generator seed for reproducibility
rng('default');
tic
% prepare input parameters to call Matlab funxction MidpointFSLVectorized
tspan =[0,T];
X0=[S0;V0];
ExpMatrixB =cell (2);
ExpMatrixB {1}=@(p,dW) RotMatExpdW (p,dW);
ExpMatrixB {2}=@(p,dW) RotMatExpdW (p,dW);
% calculate g1 and g2
g{1}=@(x)[sqrt(x(2 ,:)).*x(1 ,:);zeros (1, size(x ,2))];
g{2}=@(x)[zeros (1, size(x ,2));sigma*sqrt(x(2 ,:))];
gJac {1}=@(x) getgJac1 (x);
gJac {2}=@(x) getgJac2 (x);
% A1 and A2
B=cell (2);
Bexp=cell (2);
B{1}= zeros (2);
B{2}= zeros (2);
Bexp {1} = @(W) ExpMatrixB {1}(0 ,W);
Bexp {2} = @(W) ExpMatrixB {1}(0 ,W);
% generate Brownian motions
Z1 = randn(Nt ,Nsim);
Z2 = randn(Nt ,Nsim);
dW1 = cell (2 ,1);
dW1 {1} = sqrt(h)*Z1;
dW1 {2} = rho*dW1 {1} + sqrt(h)*sqrt (1 - rho ^2)*Z2;
% generate Brownian motions for antithetic paths
dW2 = cell (2 ,1);
dW2 {1} = -dW1 {1};
dW2 {2} = rho*dW2 {1} + sqrt(h)*sqrt (1 - rho ^2)*-Z2;
A=[r,0;0,- kappa ];
g0 =@(x) getg0(x);
g0Jac =@(x) getgJac0(x);
% generate asset price at maturity
[~,~,X1] = MidpointFSLVectorized (X0 ,A,g0 ,B,g,tspan ,h,dW1 ,g0Jac,gJac ,Bexp);
% returns price at expiration , and price and volatility paths
X1 = real(X1);
% generate antithetic paths price at maturity
[~,~,X2] = MidpointFSLVectorized (X0 ,A,g0 ,B,g,tspan ,h,dW2 ,g0Jac,gJac ,Bexp); 
% returns antithetic price at expiration , and price and volatility paths
X2 = real(X2);
% calculate the price of the European option
if strcmp(type ,'call')
    payoff = max(X1(1 ,:)-K ,0);
    antithetic_payoff = max(X2(1 ,:)-K ,0);
elseif strcmp(type ,'put')
    payoff = max(K - X1(1 ,:) ,0);
    antithetic_payoff = max(K - X2(1 ,:) ,0);
end
payoff_mean = mean(payoff);
payoff_std = std(payoff);
antithetic_payoff_mean = mean( antithetic_payoff );
antithetic_payoff_std = std( antithetic_payoff );
option_price = R*0.5*( payoff_mean + antithetic_payoff_mean );
std_deviation = 0.5* sqrt( payoff_std ^2+ antithetic_payoff_std ^2);
elapsed_time = toc;
%% Functions for calling Midpoint FSL
function [erg ,inverg ]= RotMatExpdW (lambda ,dW)
    %calculate Matrix exponentials expm([0 -lambda;lambda 0]*dW(i)) and their inverses and save them in erg(:,:,i) and inverg(:,:,i), respectively.
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
