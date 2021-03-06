function [varargout] = plotCorr(data,varargin)

% create a correlation plot in the standard decathlon format

% parse inputs
fs = 9;
cluster = true;
for i=1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
    switch arg
        case 'Labels'
            i=i+1;
            labels = varargin{i};       % column labels for raw data
        case 'FontSize'
            i=i+1;
            fs = varargin{i};           % plot font size
        case 'Cluster'
            i=i+1;
            cluster = varargin{i};
    end
    end
end

% calculate covariance matrix
[r,p] = corrcoef(data,'rows','pairwise');

% replace NaNs
r(isnan(r))=0;
p(isnan(p))=1;

% sort rows and columns by hierarchical clustering
Zoutperm = 1:length(r);
if cluster
    Z=linkage(r,'single','spearman');
    f=figure;
    [ZH, ZT, Zoutperm]=dendrogram(Z,length(r));
    close(f);
    r=r(Zoutperm,Zoutperm);
    p=p(Zoutperm,Zoutperm);
end

% plot correlation matrix
fh=figure;
imh = imagesc(r);
egoalley=interp1([1 47 128 129 169 256],...
    [0 1 1; 0 .2 1; 0 0 0; 0 0 0 ; 1 .1 0; 1 1 0],1:256);
colormap(egoalley);
colorbar
caxis([-1,1]);
set(gca,'TickLength',[0 0]);    

if exist('labels','var')
    clusteredLabels=labels(Zoutperm);

    % format field labels for display
    for i = 1:length(clusteredLabels)
        tmp = clusteredLabels{i};
        tmp(tmp=='_')=' ';
        clusteredLabels(i)={tmp};
    end
    
    set(gca,'Ytick',1:length(clusteredLabels),'YtickLabel', clusteredLabels,'fontsize',fs);
    set(gca,'XTick',1:length(labels),'XTickLabel',clusteredLabels,'fontsize',fs,'XTickLabelRotation',45);
    
end

%% plot pvalues

figure();imagesc(p);colorbar;
c=[0 1 1];
logcmap =interp1([1 256*1/3*0.5 256*2/3*0.5 256*0.5 256],...
    [c./1; c./10; c./100; c./1000; c./10000],1:256);
colormap(logcmap);
set(gca,'Ytick',1:length(clusteredLabels),'YtickLabel', clusteredLabels,'fontsize',fs);
set(gca,'XTick',1:length(labels),'XTickLabel',clusteredLabels,'fontsize',fs,'XTickLabelRotation',45);
set(gca,'TickLength',[0 0]);

%% parse outputs

for i = 1:nargout
    switch i
        case 1, varargout(i)={fh};
        case 2, varargout(i)={r};
        case 3, varargout(i)={p};
        case 4, varargout(i)={Zoutperm};
    end
end

