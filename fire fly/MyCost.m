function [z,sol] = MyCost(sol1,model)

    sol=ParseSolution(sol1,model);     
    
    beta=100;                         % Penalty Coefficient

    z=sol.L*(1+beta*(sol.Violation+0.5*sol.Vio));   % Cost Function Definition
end