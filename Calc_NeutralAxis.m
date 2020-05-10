function calc_neutralaxis = Calc_NeutralAxis(myRectangularSection, myConcrete, mySteel, approximate)
    b = myRectangularSection.width;
    c = myRectangularSection.clearcover;
    d = myRectangularSection.getEffectiveHeight();
    
    As = myRectangularSection.getSteelAreaTop();
    As_1 = myRectangularSection.getSteelAreaBottom();
    
    Ec = myConcrete.Ec;
    Es = mySteel.E0;
    
    n = Es/Ec;
    
    if approximate == 1
        % Approximate formula (negative result)
        
        
        % Neutral axis
        %x = n*(As+As_1)/b*(-1+sqrt(1+(2*b*(As*d+As_1*myRectangularSection.clearcover))/(n*(As+As_1)^2)));

        x = 1.25*As/b*mySteel.Fy/myConcrete.fc;
        calc_neutralaxis = x;
    else
        % Translation balancement
        % Nc + Ns1 + Ns = 0
        
        syms x;
        
        Sn = b*(x^2/2)+n*As_1*(x-myRectangularSection.clearcover)-n*As*(d-x)-2*(pi*10^2)*(x-(d/4))-2*(pi*10^2)*(d-(d/2)-x)-2*(pi*10^2)*(d-(d/2)-x+(d/4)) == 0;
        %Sn = b*(x^2/2)+n*As_1*(x-myRectangularSection.clearcover)-n*As*(d-x)-2*(pi*10^2)*(x-(d/4))-2*(pi*10^2)*(d-(d/2)-x)-2*(pi*10^2)*(d-(d/2)-x+(d/4)) == 0;
        
        %Sn = b*(x^2/2)+n*As_1*(x-myRectangularSection.clearcover)-n*As*(d-x) == 0;
        x_neutral_axis = solve(Sn, x);
        
        % There are two solutions, we take the positive one
        if x_neutral_axis(1) > 0
            x_neutral_axis = x_neutral_axis(1);
        else
            x_neutral_axis = x_neutral_axis(2);
        end
        
        calc_neutralaxis = double(x_neutral_axis);
    end
end