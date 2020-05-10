classdef concreteClass
   properties
      fc;
      epsc0;
      epscu;
      Ec;
   end
   methods
      function obj = concreteClass(fc, epsc0, epscu, Ec)
        obj.fc = fc;
        obj.epsc0 = epsc0;
        obj.epscu = epscu;
        obj.Ec = Ec;
      end
   end
end