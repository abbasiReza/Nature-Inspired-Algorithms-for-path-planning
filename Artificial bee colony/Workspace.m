function md=Workspace()
%% Required Parameters
n = 5;
Trajectory = menu('select Path','Workspace A','Workspace B',...
    'Workspace C','Workspace D','Workspace E','Workspace F','random');

%% Random Obstacles Layout

switch Trajectory
    case 1
    xcc = [.5 1.5 2.5 .5  1.5 2.5 .5  1.5 2.5]';
    ycc = [.5 1.5 2.5 1.5 2.5 .5  2.5 .5  1.5]';
    rr = .3*[1 1 1 1 1 1 1 1 1]';
    OBS = size(rr,1); xs=0; ys=0; xt=3; yt=3;
    case 2
    xcc = [-.5 0 .5 1.5 1.5 .5 2 2.5 3 3.5 4]';
    ycc = [1 1 1 1 2.5 2.5 2.5 2.5 2.5 2.5 2.5]';
    rr  = .6*[.5 .5 .5 .5 .5 .5 .5 .5 .5 .5 .5]';
    OBS = size(rr,1); xs=0; ys=0.3; xt=3; yt=3;
    case 3
    xcc = [.5  1 1.8  2 2.5 2.5 3 3.3 3.7  2]';
    ycc = [.7 .7 1.7 .3 1.5 .6  1.2 .4  1.7 1]';
    rr=.2*[.8   1  1   1  1   1  1  1   1   .8]';
    OBS = size(rr,1); xs=0; ys=0.3; xt=4; yt=0.8;
    case 4
    xcc = [.5 .5  1.5 1.5 2.5 2.5  3.5]';
    ycc = [.9 1.9  2.4  1.4   .9  2.2   1.4]';
    rr=.3*[1 1 1 1 1 1 1]';
    OBS = size(rr,1); xs=0; ys=0.7; xt=4; yt=1.6;
    case 5
    xcc = [2.6709 2.3264 0.7585 3.3423 1.9928 1.0297 2.1093 3.2211 3.1555 1.7923]';
    ycc = [1.6641 1.4676 1.0830 2.1307 1.1979 1.7839 1.5938 2.3283 1.0319 2.4661]';
    rr  = [0.2432 0.2376 0.2733 0.3094 0.2304 0.2324 0.3465 0.2890 0.2457 0.2452]';
    OBS = size(rr,1); xs=0; ys=1.5; xt=4; yt=1.6;
    case 6
    xcc = [3.1710 3.4470 0.8462 2.3585 0.9545 2.1739 2.1453 1.2626 1.7712]';
    ycc = [1.1131 2.2006 1.2458 2.0110 1.5818 1.5621 2.4271 1.3175 2.0712]';
    rr  = [0.3052 0.2710 0.3269 0.2364 0.2361 0.2885 0.3039 0.3403 0.2369]';
    OBS = size(rr,1); xs=0; ys=1.5; xt=4; yt=1.6;
    case 7
    prompt = {'please enter x of start point'};
    xs = inputdlg(prompt);
    xs = str2double(xs);
    prompt = {'please enter y of start point'};
    ys = inputdlg(prompt);
    ys = str2double(ys);

    prompt = {'please enter x of end point'};
    xt = inputdlg(prompt);
    xt = str2double(xt);

    prompt = {'please enter y of end point'};
    yt = inputdlg(prompt);
    yt = str2double(yt);
    prompt = {'please enter number of obs'};
    OBS = inputdlg(prompt);
    OBS = str2double(OBS);

    rr=0.5 + (1-0.5) .* rand(OBS,1);

    xcc=rand(OBS,1)*4;
    ycc=rand(OBS,1)*4;

end

%% Plot Obstacles
figure (100)
    plot(xs,ys,'ks','MarkerSize',8);
    hold on
    plot(xt,yt,'ko','MarkerSize',8);
%     legend('Start Point','Target Point');
hold on
title 'Workspace'
xlabel 'X[m]'
ylabel 'Y[m]'
theta=linspace(0,2*pi,100);
for i=1:OBS
    fill(xcc(i)+rr(i)*cos(theta),ycc(i)+rr(i)*sin(theta),'k');
    hold on
end
axis equal

md.n=n;
md.OBS=OBS; md.r=rr; md.xc=xcc; md.yc=ycc;
md.xs=xs; md.ys=ys;
md.xt=xt; md.yt=yt;
% save md
end