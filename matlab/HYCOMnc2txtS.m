function timeSer = HYCOMnc2txtS(latPoint,lonPoint,startDate,endDate,depth,missingV,scaleF,flag1)
% ___________________________________________
% Function that downloads the marine components currents from HYCOM Hindcast data, 
% using an OpeNDAP url, from Dec-04-2018 to present each 3-hourly.
% 
% This script uses the nctoolbox-1.1.3 (Schilining et al., 2009), for this 
% reason, remember to load the path of the toolbox and set  it, before to run 
% the script.
% 
% Inputs:
%   latPoint and lonPoint = geographical coordinates of the point dataset.
%   starDate and endDate = the time span of the data analysis.
%   depth = number of vertical layer.
%   missingV = value to recognize missing values in the time series.
%   scaleF = scale factor of the data.
%   flag1 to export the data to txt file. flag = 1 to export the data, other
%        number to not export.
%
% Outputs:
%	timerSer = matrix with the values downloaded.
%   1 to 6th columns = date and time.
%   7 and 8th colums = u and v current components.
%
% Relevant notes.
% - This function only downloads A POINT DATASET of one vertical layer.
% - The dataUrl and dataUrl1 variables should be edited in order to use other
%   hindcast HYCOM dataset.
% - In order to use NCTOOLBOX, you must charge the path of the toolbox and setup in your 
%   Matlab session, e.g.
%           addpath(genpath('PATH WHERE THE NCTOOLBOX FILES ARE DOWNLOADED'));
%           setup_nctoolbox;
%
% Example:
%   latPoint = 19.080;
%   lonPoint = 255.52;
%	startDate = '01-Jan-2020';
%	endDate = '02-Jan-2020';
%	depth = 2;
% 	missingV = -30000;
%	scaleF = 0.001;
%   flag1 = 0;
% 	timeSer = HYCOMnc2txtS(latPoint,lonPoint,startDate,endDate,depth,missingV,scaleF,flag1);
%
% Reference:
% B. Schlining, R. Signell, A. Crosby, nctoolbox (2009), Github repository, 
% https://github.com/nctoolbox/nctoolbox. 
% 
% The function is provide "as is", without warranty of any kind, express or implied.
%
% Author: Gabriel Ruiz Martinez.
% Date: Apr-2021.
% ___________________________________________

if exist('ncgeodataset','file') == 0
    error('NCTOOLBOX is not loaded!')
end

% ***********************************
dataUrl = 'https://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0/uv3z?';
dataUrl1 = horzcat(dataUrl,'lat[0:1:4250],lon[0:1:4499],time[0:1:6770]');
% ***********************************

fprintf('Downloading the longitude array\n');
longin = ncread(dataUrl1,'lon');

fprintf('Downloading the latitude array\n');
latit = ncread(dataUrl1,'lat');

fprintf('Downloading the time array\n');
timedata = ncread(dataUrl1,'time');

[lap,~] = find(round(latit.*100)./100 == latPoint);
[lop,~] = find(round(longin.*100)./100 == lonPoint);

time2 = datetime(2000,01,01,0,0,0)+(timedata./24);
timeM = datevec(time2);

tempd1 = datenum(startDate,'dd-mmm-yyyy');
tempd2 = datenum(endDate,'dd-mmm-yyyy');

[di,~] = find(datenum(timeM) == tempd1);
[de,~] = find(datenum(timeM) == tempd2);

nrec = di:1:de;
curData = NaN(length(nrec),2);

data = ncgeodataset(dataUrl);

for i = 1 : length(nrec)
    curData(i,1) =data{'water_u'}(nrec(i),depth,lap,lop);
    fprintf('Download u_water, date: %4d-%02d-%02d %02d Hrs\n',...
	timeM(nrec(i),1),timeM(nrec(i),2),timeM(nrec(i),3),timeM(nrec(i),4));
end

for i = 1 : length(nrec)
    curData(i,2) =data{'water_v'}(nrec(i),depth,lap,lop);
    fprintf('Download v_water, date: %4d-%02d-%02d %02d Hrs\n',...
	timeM(nrec(i),1),timeM(nrec(i),2),timeM(nrec(i),3),timeM(nrec(i),4));
end

for k = 1 : 2
     [temp,~] = find(curData(:,k) == missingV);
     curData(temp,k) = NaN;
end

curData = curData.*scaleF;
timeSer = [ timeM(di:1:de,:) curData ];

fprintf('Plotting...\n');

figure;
subplot(2,1,1)
plot(datenum(timeSer(:,1:6)),curData(:,1),'LineStyle','none','Marker',".");
ylabel('Eastward Sea Water Velocity (m/s)');
xlabel('Date');
datetick('x',25);

subplot(2,1,2)
plot(datenum(timeSer(:,1:6)),curData(:,2),'LineStyle','none','Marker',".",'Color',"r");
ylabel('Northward Sea Water Velocity (m/s)');
xlabel('Date');
datetick('x',25);

nFile = horzcat('U_VwaterLat',num2str(latPoint),'Lon',num2str(latPoint),'D',startDate,'_',endDate,'.txt');
save(horzcat(nFile(1:end-4),'.mat'),'timeSer','-mat');

if flag1 == 1
    fid = fopen(nFile,'w');
    for l = 1 : length(timeSer)
        fprintf(fid,'%4d %02d %02d %02d %02d %02d %9.5f %9.5f\r\n',...
            timeSer(l,1),timeSer(l,2),timeSer(l,3),timeSer(l,4),...
            timeSer(l,5),timeSer(l,6),timeSer(l,7),timeSer(l,8));
    end
end
