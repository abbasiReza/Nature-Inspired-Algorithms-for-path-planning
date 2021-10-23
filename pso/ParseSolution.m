function sol2=ParseSolution(sol1,model)
%% Import Data
x=sol1.x;                % Initial Solution: X-Dimention
% x=sort(x);             % Sort Splines: X-Dimention
y=sol1.y;                % Initial Solution: Y-Dimention
% y=sort(y);             % Sort Splines: Y-Dimention
OBS=model.OBS;           % Number of Obstacles
xs=model.xs;             % Start Point: X-Dimention
ys=model.ys;             % Start Point: Y-Dimention
xt=model.xt;             % Target Point: X-Dimention
yt=model.yt;             % Target Point: Y-Dimention
xc=model.xc;             % Centre of Obstacles: X-Dimentions
yc=model.yc;             % Centre of Obstacles: Y-Dimentions
r=model.r;               % Radius of Obstacles
ttt=model.ttt;           % Time Interval

%% Splines
XS=[xs x xt];            % X-Spline
YS=[ys y yt];            % Y-Spline
k=numel(XS);             % Number of Spline Points Including Start P0int and End Point
TS1=linspace(0,ttt,k);    % Splitting Time Interval Between Spline

%% Creating Path
tt=0:1:ttt;
xx1=spline(TS1,XS,tt);
yy1=spline(TS1,YS,tt);
%% Path Length
dX=diff(xx1);
dY=diff(yy1);
L=sum(sqrt(dX.^2+dY.^2));

% Calculate new Spline points based on edge lengths
for i=1:numel(XS)
    dx=diff(XS(1:i));
    dy=diff(YS(1:i));
    l(i)=sum(sqrt(dx.^2+dy.^2));
    TS(i)=ttt*l(i)/L;  % Actual spline breakpoints
end
TS=TS1;
xx=spline(TS,XS,tt);    % Actual Path Samples (x)
yy=spline(TS,YS,tt);    % Actual Path Samples (y)
%% Calculating Violtions
Violation = [1 OBS];
for i=1:OBS
    d= sqrt((xx-xc(i)*ones(1,length(xx))).^2+(yy-yc(i)*ones(1,length(xx))).^2);
    v= max((ones(1,length(xx))-(d./(r(i)+0.05))),0);
    Violation(i) = mean(v);
end

spx = diff(xx)./diff(tt);
spy = diff(yy)./diff(tt);
spd = sqrt(spx.^2 + spy.^2);

Vmax = 0.12;                       % Maxsimum Velocity
vio = max(1-(Vmax./spd),0);
Vio = mean(vio);
alpha=1;
Vio = ones(1,OBS).*Vio.*alpha;    % Velocity Violation

%% Export Data
sol2.OBS=OBS;
sol2.TS=TS;
sol2.XS=XS;
sol2.YS=YS;
sol2.tt=tt;
sol2.xx=xx;
sol2.yy=yy;
sol2.dx=dx;
sol2.dy=dy;
sol2.L=L;
sol2.Violation=Violation;
sol2.IsFeasible=(Violation==zeros(1,OBS));
sol2.Vio=Vio;
sol2.spd=spd;
end
