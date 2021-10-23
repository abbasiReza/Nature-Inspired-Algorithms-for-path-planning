function model=CreateModel()
%% Model Definition
ttt=50;        % Time Interval from Start to Target
xmin= 0;      % Lower Bound of X
xmax= 4;       % Upper Bound of X
ymin= 0;      % Lower Bound of y
ymax= 4;       % Upper Bound of y

md=Workspace();    % Loading Environment

%% Export Model
model.xs=md.xs;
model.ys=md.ys;
model.xt=md.xt;
model.yt=md.yt;
model.xc=md.xc;
model.yc=md.yc;
model.r=md.r;
model.OBS=md.OBS;
model.n=md.n;
model.xmin=xmin;
model.xmax=xmax;
model.ymin=ymin;
model.ymax=ymax;
model.ttt=ttt;
end