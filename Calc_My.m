function calc_my = Calc_My(N,myRectangularSection, myConcrete, mySteel)
    Ec = myConcrete.Ec;
    Es = mySteel.E0;
    
    N = N*1000; % [N]
    
    n = Es/Ec; % Coefficiente di omogeneizzazione
    c = myRectangularSection.clearcover;
    d = myRectangularSection.getEffectiveHeight(); % Cross section effective depth
    d_1 = c+myRectangularSection.rebarsdiam/2; % Distance of the center of compression reinforcement from the extreme compression fibers
    
    h = myRectangularSection.height;
    % delta_1
    % Ratio between the cross section effective depth (d) and the 
    % distance of the center of the compression reinforcement from 
    % the extreme compression fibers (d')
    delta_1 = d_1/d;
    
    A_letter_steel = myRectangularSection.getRhoTotal()+(N/(myRectangularSection.width*myRectangularSection.height*mySteel.Fy));
    B_letter_steel = myRectangularSection.getRhoTop()+myRectangularSection.getRhoBottom()*delta_1+(0.5*myRectangularSection.getRhoCenter()*(1+delta_1))+(N/(myRectangularSection.width*myRectangularSection.height*mySteel.Fy));
    k_y_s = sqrt(n^2*A_letter_steel^2+2*n*B_letter_steel)-(n*A_letter_steel);
    theta_y_s = mySteel.Fy/(Es*(1-k_y_s)*d);
    
    A_letter_concrete = myRectangularSection.getRhoTotal()-(N/(myConcrete.epsc0*Es*myRectangularSection.width*d));
    B_letter_concrete = myRectangularSection.getRhoTop()+myRectangularSection.getRhoBottom()*delta_1+(0.5*myRectangularSection.getRhoCenter()*(1+delta_1));
    k_y_c = sqrt(n^2*A_letter_concrete^2+2*n*B_letter_concrete)-(n*A_letter_concrete);
    theta_y_c = (1.8*abs(myConcrete.fc))/(Ec*k_y_c*myRectangularSection.getEffectiveHeight());

    % Compression area depth yielding (normalized respect of d)
    if (theta_y_c > theta_y_s)
        k_y = k_y_s;
    else
        k_y = k_y_c;
    end

        
    % Reinforcement ratios
    % In questo caso è uguale perchè il numero dei ferri è lo stesso
    rho_s = myRectangularSection.getRhoTop(); % tension
    rho_1s = myRectangularSection.getRhoBottom(); % compression
    
    rho_w =  myRectangularSection.getRhoCenter(); % web reinforcement
    
    % Approximate variable values
    % 1 -> Use approximated neutral axis formula
    % 0 -> Use force balancement
    approximate = 0;
    x = abs(Calc_NeutralAxis(myRectangularSection, myConcrete, mySteel, approximate));
    
    %Mu = As*mySteel.Fy*(d-2/5*x);
    %My = Mu/1.13;

    % Yield curvature (curvatura di snervamento)
    % phi_y = eps_y/(myRectangularSection.getEffectiveHeight()-(myRectangularSection.getEffectiveHeight()/2));
    
    %phi_y = 0.00074;
    
    %phi_y = -(myConcrete.epscu/x); % [rad/mm]
    
    %k_y = 0.3243117;
    
    eps_sy = mySteel.Fy/Es;
    
    dst = (d-x-myRectangularSection.rebarsdiam);
    phi_y = atan(eps_sy/dst); % [rad/mm]
    %phi_y = phi_y*1000; % [rad/m]
    
    %syms y;
    %eq = (d-x+y) == 317.3928;
    %yy = double(solve(eq,y));
    
    %phi_y = 7.4573e-06;
    %xx = eps_sy/phi_y;
    
    part1 = Ec*(k_y^2/2)*(0.5*(1+delta_1)-(k_y/3));
    part2 = Es/2*((1-k_y)*rho_s+(k_y-delta_1)*rho_1s+(rho_w/6)*(1-delta_1))*(1-delta_1);
    UArea = myRectangularSection.width*(d)^3;
    
    calc_my = phi_y*(part1+part2)*UArea;
    
    %My = 4.3748e+08;
    %phi_y = My/((part1+part2)*UArea);
    %a = 0;
end
