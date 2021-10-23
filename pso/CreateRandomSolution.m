function sol1=CreateRandomSolution(model)

n=model.n;          % Number of Splines

xmin=model.xmin;    % Lower Bound of X
xmax=model.xmax;    % Upper Bound of X

ymin=model.ymin;    % Lower Bound of Y
ymax=model.ymax;    % Upper Bound of Y

sol1.x=unifrnd(xmin,xmax,1,n);   % Random Solution X- Position
sol1.y=unifrnd(ymin,ymax,1,n);   % Random Solution Y-Position
end