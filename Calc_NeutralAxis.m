% MIT License

% Copyright (c) 2020 Vincenzo Tartaglia

% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
