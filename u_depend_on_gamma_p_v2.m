

%%  Snipe or not to snipe!
%latest version 03 July 2019
% fid      'kks.2019.07.03.16.01.33.070'

addpath C:\Users\Home_Level_2\Dropbox\KAREN\aux_functions
   
%corresponding value of u* in p* and gamma_bar

clear all
close all
%each p belongs to Gamma respectively. I calculated them from
%Examples_transition_gamma_L_K.m
p1= 0.0524
p2=0.0352
p3=0.0211
p4=0.0025
p5=-8.2644e-05
P=[p1 p2 p3 p4 p5]

alpha= .5;
mu= .45;
delta=.5;
sigma= 1;
H=5;
mz_params.H = H; 
mz_params.alpha = alpha ;
mz_params.mu = mu;
mz_params.delta = delta; 
mz_params.sigma = sigma;

disp('MZ game with the following parameters')
disp(mz_params)

%  COmpute the corresponding gamma thresholds
[gamma_bar_K, gamma_bar_L] = sniping_thresholds_gamma_bar_L_and_K(mz_params);
disp('Sniping transitions thresholds: ')
disp(['   gamma_bar_K = ', num2str(gamma_bar_K)])
disp(['   gamma_bar_L = ', num2str(gamma_bar_L)])

%  Create arrays for gamma and result
gamma_step = 0.01
Gamma = (1:gamma_step:8)
U_gamma = [];  %zeros(size(Gamma));
U_gamma_sure = [];  %zeros(size(Gamma));
P_star = [];

%Gamma=[1 1.7575  2.5150    5.1732    7.8313]

for gamma = Gamma
 mz_params.gamma = gamma 
 
 if gamma <= gamma_bar_K  %  sure sniping is optimal 
    mz_params.p = 1;    % only look at sure sniping 
    [s_star,u_star,A_p,B_p,C_p,D_p] = MZ_game_optimal_spread_utility(mz_params);
    U_gamma=[U_gamma  u_star ];
    U_gamma_sure = [U_gamma_sure  u_star];   %  result for sure sniping 
    P_star = [P_star 1];
    
 elseif gamma >= gamma_bar_L  %  NO sniping is optimal
     % First result for sure sniping 
    mz_params.p = 1;    % only look at sure sniping 
    [s_star,u_star,A_p,B_p,C_p,D_p] = MZ_game_optimal_spread_utility(mz_params);
    U_gamma_sure = [U_gamma_sure u_star];
    
    U_gamma=[U_gamma  0];
    P_star = [P_star 0];
    
    
 elseif  gamma_bar_K < gamma  &  gamma < gamma_bar_L  % this is where non-trivial sniping is advantageous
    %  First compute the result for sure sniping 
     mz_params.p = 1; 
     [s_star,u_star,A_p,B_p,C_p,D_p] = MZ_game_optimal_spread_utility(mz_params);
     U_gamma_sure = [U_gamma_sure  u_star];
     
     % Next, compute the result for probabilistic sniping
    P_try =(0.99:-0.001:0.01);   %  prob that we will try (and loop over) 
    u_star_this_gamma = [];
    for p_now = P_try    %  cycle over all sniping probs
         mz_params.p = p_now;    % only look at sure sniping 
         [s_star,u_star,A_p,B_p,C_p,D_p] = MZ_game_optimal_spread_utility(mz_params);
         u_star_this_gamma = [u_star_this_gamma u_star];
    end
    [u_star_max,u_star_max_arg] = max(u_star_this_gamma);
    U_gamma=[U_gamma  u_star_max ];
    P_star = [P_star P_try(u_star_max_arg)];
    
 end


end

Gamma_thresholds = [gamma_bar_K  gamma_bar_L];
gamma_min = min(Gamma);
gamma_max = max(Gamma); 

figure(2), 
    plot(Gamma,U_gamma, 'r-', [gamma_min gamma_max], zeros(1,2),'k' ,  ...
       Gamma_thresholds, zeros(1,2),'bo')
   text(Gamma_thresholds(1)-0.05,-0.005,'$\overline\gamma_K$','interpreter','latex','FontSize',16)
   text(Gamma_thresholds(2)-0.05,-0.005,'$\overline\gamma_L$','interpreter','latex','FontSize',16)
   title('Optimal utility $u^*(s^*,p^*_K)$ as function of risk aversion $\gamma$', 'interpreter','latex','FontSize',16)
   xlabel('Risk aversion  $\gamma$','interpreter','latex','FontSize',16)
   
   
figure(3), 
    plot(Gamma,U_gamma_sure, 'b-', Gamma,U_gamma, 'r-', [gamma_min gamma_max], zeros(1,2),'k' ,  ...
       Gamma_thresholds, zeros(1,2),'bo')
     text(Gamma_thresholds(1)-0.05,-0.01,'$\overline\gamma_K$','interpreter','latex','FontSize',16)
   text(Gamma_thresholds(2)-0.05,-0.01,'$\overline\gamma_L$','interpreter','latex','FontSize',16)
   title('Comparison btw sure sniping (blue) and optimal prob sniping (red)')
   xlabel('Risk aversion factor $\gamma$','interpreter','latex','FontSize',16)
   ylabel('Optimal utility $u^*$','interpreter','latex','FontSize',16)

    
figure(4), 
subplot(2,1,1)
    plot(Gamma,U_gamma_sure, 'b-', Gamma,U_gamma, 'r-', [gamma_min gamma_max], zeros(1,2),'k' ,  ...
       Gamma_thresholds, zeros(1,2),'bo')
     text(Gamma_thresholds(1)-0.05,-0.01,'$\overline\gamma_K$','interpreter','latex','FontSize',16)
   text(Gamma_thresholds(2)-0.05,-0.01,'$\overline\gamma_L$','interpreter','latex','FontSize',16)
   title('Utility for sure (blue) and optimal prob sniping (red)','interpreter','latex','FontSize',14 )
   xlabel('Risk aversion factor $\gamma$','interpreter','latex','FontSize',14)
   ylabel('Optimal utility $u^*$','interpreter','latex','FontSize',14)
subplot(2,1,2)   
  plot(Gamma,P_star, 'r-',  [gamma_min gamma_max], zeros(1,2),'k' ,  ...
       Gamma_thresholds, zeros(1,2),'bo')
     text(Gamma_thresholds(1)-0.05,+0.075,'$\overline\gamma_K$','interpreter','latex','FontSize',16)
   text(Gamma_thresholds(2)-0.05,+0.075,'$\overline\gamma_L$','interpreter','latex','FontSize',16)
   title('Optimal sniping prob $p_K^*$ as function of risk aversion $\gamma$','interpreter','latex','FontSize',14 )
   xlabel('Risk aversion factor $\gamma$','interpreter','latex','FontSize',14)
   ylabel('Optimal sniping prob $p_K^*$','interpreter','latex','FontSize',14)
   ylim([0 1.1])
   
    
    