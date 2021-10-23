function y=Mutate(x,mu,VarMin,VarMax)

    nVar=numel(x);
    
    nmu=ceil(mu*nVar);
    
    j=randsample(nVar,nmu);
    
    sigma.x=0.1*(VarMax.x-VarMin.x);
    
    sigma.y=0.1*(VarMax.y-VarMin.y);
    
    y=x;
    y(j).x=x(j).x+sigma.x*randn(size(j));
    y(j).y=x(j).y+sigma.y*randn(size(j));
    
    y.x=max(y.x,VarMin.x);
    y.y=max(y.y,VarMin.y);

    y.x=min(y.x,VarMax.x);
    y.y=min(y.y,VarMax.y);

end