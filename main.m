% --------------------------------------------------------
% OPENSEES ModIMKPeakOriented PARAMETERS CALCULATOR
% --------------------------------------------------------
% Author : Vincenzo Tartaglia
% Website: www.vincenzotartaglia.net
% --------------------------------------------------------

% SECTION DATA
section_width = 350; % [mm]
section_height = 350; % [mm]
section_spacing = 37; % Reinforcement spacing [mm]
section_clearcover = 30; % Clear cover [mm]
section_rebarsdiam = 20; % Rebars diameter [mm]
section_rebarstopnum = 3;
section_rebarsbottomnum = 3;
section_rebarsmidnum = 2;
myRectangularSection = rectangularSectionClass(section_width, section_height, section_spacing, section_clearcover, section_rebarsdiam, section_rebarstopnum, section_rebarsbottomnum, section_rebarsmidnum);

clear -regexp ^section_;

% CONCRETE DATA
concrete_fc = -24.4; % Compressive stress of unconfined concrete [MPa]
concrete_epsc0 = -0.002; % ec
concrete_epscu = -0.0035; % ecu
concrete_Ec = 32000; % N/mm^2 [MPa]
myConcrete = concreteClass(concrete_fc, concrete_epsc0, concrete_epscu, concrete_Ec);

clear -regexp ^concrete_;

% DATI ACCIAIO
steel_Fyk = 573;
steel_Fy = steel_Fyk; % CHANGE IT WITH YOUR VALUE
steel_b = 0.0157; % strain hardening ratio
steel_E0 = 203000; % (Steel elastic modulus) [MPa] = [N/mm^2]
mySteel = steelClass(steel_Fyk, steel_Fy, steel_b, steel_E0);

clear -regexp ^steel_;

% OTHER DATA
P = 1015.04; % Applied force at the top [kN]
Lv = 1600; % Column depth [mm]

% Calculating ModIMKPeakOriented data
Ag = myRectangularSection.width*myRectangularSection.height; % Gross cross section area [mm^2]
d = myRectangularSection.getEffectiveHeight();
ni = abs(P*1000/(Ag*myConcrete.fc)); % Axial load ratio
a_sl = 1; % Rebar slip indicator variable (0 or 1)

disp('ni (Axial load ratio) :');
disp(ni);

% Calculating Section Inertia
I = myRectangularSection.getInertiaY();
% You can also calculate the Z Inertia
%I = myRectangularSection.getInertiaZ();

% K0 = Initial secant stiffness at 40% of yielding moment
k04 = 0.17+1.61*ni;
if k04 < 0.35 || k04 > 0.80
    if k04 < 0.35
        k04 = 0.35;
        disp('k04 = 0.35 (minimum because out of range)');
    elseif k04 > 0.80
        k04 = 0.80;
        disp('k04 = 0.80 (maximum because out of range)');
    end
else
    fprintf('k04 = %0.2f',k04);
end

K0 = k04*(6*myConcrete.Ec*I/Lv); % Initial Stiffness
K0 = K0*1.1;

disp('K0 :');
disp(K0);

% Calculating yielding secant stiffness
k_y = 0.065 + 1.05*ni;
if k_y < 0.20 || k_y > 0.60
    if k_y < 0.20
        k_y = 0.20;
        disp('k_y = 0.20 (minimum because out of range)');
    elseif k_y > 0.60
        k_y = 0.60;
        disp('k_y = 0.60 (maximum because out of range)');
    end
else
    fprintf('k_y = %0.2f',k_y);
end
Ky = k_y*(6*myConcrete.Ec*I/Lv);
disp('Ky :');
disp(Ky);

% Calculating My
My = Calc_My(P, myRectangularSection, myConcrete, mySteel);
My_Plus = My; % positive loading direction
My_Neg = -My; % negative loading direction

disp('My :');
disp(My);

% Calcolo Mc
alfa_y = 1.25*(0.89)^ni*(0.91)^(0.01*abs(myConcrete.fc));
Mu = alfa_y*My;
Mc = 0;

disp('Mu :');
disp(Mu);

disp('Mc :');
disp(Mc);

% This is an array containing all the moments
Moments = [0 My Mu Mc];

% Effective yield strength - Yield Moments
% Can be calculated graphically or computed

sd_ratio = myRectangularSection.spacing/myRectangularSection.getEffectiveHeight();
lambda = 170.7*(0.27)^ni*(0.10)^sd_ratio;
theta_y = My/Ky;
theta_2 = theta_y;

Lambda_S = lambda*theta_2;
Lambda_C = Lambda_S;
Lambda_A = Lambda_S*1000;
Lambda_K = Lambda_A;
c_S = 1;
c_C = 1;
c_A = 1;
c_K = 1;


% Pre-capping rotation (often noted as plastic rotation capacity)

% A_sh calculated in according to the ACI-318-05 SEAOC Building Code
%A_sh = abs(0.3*myRectangularSection.spacing*myRectangularSection.getEffectiveHeight()*(myConcrete.fc/mySteel.Fy)*((myRectangularSection.getArea()/myRectangularSection.getNetArea())-1)); % Shear reinforcement area
A_sh = (pi*(8/2)^2)*3; % Considered 8mm diameter and *3 stirrups
rho_sh = A_sh/(myRectangularSection.spacing*myRectangularSection.width); % Transverse reinforcement ratio
theta_p = 0.13*(1+0.55*a_sl)*(0.13)^ni*(0.02+40*rho_sh)^0.65*(0.57)^(0.01*abs(myConcrete.fc));
%theta_p_tot = 0.14*(1+0.4*a_sl)*(0.19)^ni*(0.02+40*rho_sh)^0.54*(0.62)^(0.01*abs(myConcrete.fc));
theta_u = 0.14*(1+0.4*a_sl)*(0.19)^ni*(0.02+40*rho_sh)^0.54*(0.62)^(0.01*abs(myConcrete.fc));
theta_p_Plus = theta_p; % positive loading direction
theta_p_Neg = theta_p; % negative loading direction

theta_pc = 0.76*(0.031)^ni*(0.02+40*rho_sh)^1.02;
if theta_pc > 0.1
    theta_pc = 0.1;
    fprintf('theta_pc out of range, assumed theta_pc = 0.1\n\n');
end

theta_c = theta_u + theta_pc; % Sarebbe theta_pc_Plus e theta_pc_Neg

theta_pc_Plus = theta_pc;
theta_pc_Neg = theta_pc;
Res_Pos = 0; % default value
Res_Neg = 0; % default value
theta_u_Plus = theta_u;
theta_u_Neg = theta_u;

D_plus = 1; % default value
D_neg = 1; % default value

% Strain hardening ratio
% This parameter defines the slope of post yield behavior.
% The parameter has almost intolerent effect on the calibration.

as_Plus = abs((Mu-My)/theta_pc)*(1/K0); % positive loading direction
as_Neg = as_Plus; % negative loading direction

disp('ModIMKPeakOriented PARAMETERS CALCULATED');
fprintf('K0 = %0.2f\n', K0);
fprintf('as_Plus = %0.6f\n', as_Plus);
fprintf('as_Neg = %0.6f\n', as_Neg);
fprintf('My_Plus = %0.2f\n', My_Plus);
fprintf('My_Neg = %0.2f\n', My_Neg);
fprintf('Lambda_S = %0.2f\n', Lambda_S);
fprintf('Lambda_C = %0.2f\n', Lambda_C);
fprintf('Lambda_A = %0.0f\n', Lambda_A);
fprintf('Lambda_K = %0.0f\n', Lambda_K);
fprintf('c_S = %0.0f\n', c_S);
fprintf('c_C = %0.0f\n', c_C);
fprintf('c_A = %0.0f\n', c_A);
fprintf('c_K = %0.0f\n', c_K);
fprintf('theta_p_Plus = %0.3f\n', theta_p_Plus);
fprintf('theta_p_Neg = %0.3f\n', theta_p_Neg);
fprintf('theta_pc_Plus = %0.6f (OUT OF RANGE)\n', theta_pc_Plus);
fprintf('theta_pc_Neg = %0.6f (OUT OF RANGE)\n', theta_pc_Neg);
fprintf('Res_Pos = %0.0f\n', Res_Pos);
fprintf('Res_Neg = %0.0f\n', Res_Neg);
fprintf('theta_u_Plus = %0.3f\n', theta_u_Plus);
fprintf('theta_u_Neg = %0.3f\n', theta_u_Neg);
fprintf('D_plus = %0.0f\n', D_plus);
fprintf('D_neg = %0.0f\n\n', D_neg);

% CALCULATING SHEAR

k_val = 1; % displacement ductility required (?/?y) until 2
Lv_eff = Lv/2;
Vs = k_val*((A_sh*mySteel.Fy*d)/myRectangularSection.spacing);
Vc_1 = (0.5*sqrt(abs(myConcrete.fc)))/(Lv_eff/d);
Vc_2 = sqrt(1+((P*1000)/(0.5*sqrt(abs(myConcrete.fc))*Ag)));
Vc = k_val*Vc_1*Vc_2*0.8*Ag;
Vr = Vs+Vc;

% Failure classification (classificazione collasso)
disp('FAILURE CLASSIFICATION');
fprintf('Vr = %0.2f \n',Vr);
failure_type = 0;
failure_coeff = 0.7*Vr*Lv;
failure_coeff_2 = Vr*Lv;
if 0.7*Vr*Lv > Mu
    % Flexural failure
    failure_type = 1;
    fprintf('0.7*Vr*Lv = %f > Mu = %f (flexural failure) (collasso per flessione)\n', failure_coeff, Mu);
elseif Vr*Lv < My
    % Shear failure
    failure_type = 2;
    fprintf('Vr*Lv = %f < My = %f (shear failure) (collasso per taglio)\n', failure_coeff_2, My);
else
    % Shear-Flexural failure
    failure_type = 3;
    fprintf('Shear-flexural collapse (collasso per flessione-taglio)\n');
end
