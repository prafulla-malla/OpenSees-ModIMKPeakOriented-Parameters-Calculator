% MIT License

% Copyright (c) 2020 Vincenzo Tartaglia

% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

classdef rectangularSectionClass
   properties
      width; % Section width
      height; % Section height
      spacing; % Section spacing
      clearcover; % Clear cover
      rebarsdiam; % Rebars diameter
      rebarstopnum; % Number of rebars at the top
      rebarsbottomnum; % Number of rebars at the bottom
      rebarsmidnum;  % Number of rebars at the center
   end
   methods
      function obj = rectangularSectionClass(width, height, spacing, clearcover, rebarsdiam, rebarstopnum, rebarsbottomnum, rebarsmidnum)
        obj.width = width;
        obj.height = height;
        obj.spacing = spacing;
        obj.clearcover = clearcover;
        obj.rebarsdiam = rebarsdiam;
        obj.rebarstopnum = rebarstopnum;
        obj.rebarsbottomnum = rebarsbottomnum;
        obj.rebarsmidnum = rebarsmidnum;
      end
      function r = getInertiaY(obj)
         r = obj.width*obj.height^3/12;
      end
      function r = getInertiaZ(obj)
         r = obj.height*obj.width^3/12;
      end
      function r = getArea(obj)
         r = obj.width*obj.height;
      end
      function r = getNetArea(obj)
         eheight = obj.height-obj.clearcover;
         r = obj.width*eheight;
      end
      function r = getEffectiveHeight(obj)
         r = obj.height-obj.clearcover;
      end
      function r = getRhoTop(obj)
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarstopnum;
          r = As/(obj.width*(obj.height-obj.clearcover));
      end
      function r = getRhoBottom(obj)
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarsbottomnum;
          r = As/(obj.width*(obj.height-obj.clearcover));
      end
      function r = getRhoCenter(obj)
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarsmidnum;
          r = As/(obj.width*(obj.height-obj.clearcover));
      end
      function r = getRhoTotal(obj)
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarstopnum;
          r1 = As/(obj.width*(obj.height-obj.clearcover));
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarsmidnum;
          r2 = As/(obj.width*(obj.height-obj.clearcover));
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarsbottomnum;
          r3 = As/(obj.width*(obj.height-obj.clearcover));
          
          r = r1+r2+r3;
      end
      function r = getSteelAreaTop(obj)
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarstopnum;
          r = As;
      end
      function r = getSteelAreaBottom(obj)
          As = pi*(obj.rebarsdiam/2)^2*obj.rebarsbottomnum;
          r = As;
      end
   end
end
