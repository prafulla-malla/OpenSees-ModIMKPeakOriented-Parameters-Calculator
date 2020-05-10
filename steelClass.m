classdef steelClass
   properties
      Fyk;
      Fy;
      b;
      E0;
   end
   methods
      function obj = steelClass(Fyk, Fy, b, E0)
        obj.Fyk = Fyk;
        obj.Fy = Fy;
        obj.b = b;
        obj.E0 = E0;
      end
   end
end